package controller;

import dao.CandidateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Candidate;
import util.ImageProcessingUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Public endpoint serving candidate photos with ETag and client caching (max-age=86400).
 * If no photo is stored, dynamically serves an initial SVG avatar.
 */
@WebServlet(name = "CandidatePhotoServlet", urlPatterns = "/candidate-photo")
public class CandidatePhotoServlet extends HttpServlet {

    private final CandidateDAO candidateDAO = new CandidateDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        Integer candidateId = ValidationUtil.parsePositiveInt(idParam);

        if (candidateId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing candidate ID.");
            return;
        }

        Candidate meta = candidateDAO.getPhotoMeta(candidateId);
        if (meta == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Candidate not found.");
            return;
        }

        // Set security headers
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("Cache-Control", "public, max-age=86400");

        byte[] photoData = meta.getPhotoData();
        if (photoData != null && photoData.length > 0) {
            long updatedTime = (meta.getPhotoUpdatedAt() != null) ? meta.getPhotoUpdatedAt().getTime() : 0L;
            String etag = "W/\"cand-" + candidateId + "-" + updatedTime + "\"";
            resp.setHeader("ETag", etag);

            String ifNoneMatch = req.getHeader("If-None-Match");
            if (etag.equals(ifNoneMatch)) {
                resp.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
                return;
            }

            String contentType = meta.getPhotoType();
            if (contentType == null || contentType.trim().isEmpty()) {
                contentType = "image/png";
            }
            resp.setContentType(contentType);
            resp.setContentLength(photoData.length);

            try (OutputStream out = resp.getOutputStream()) {
                out.write(photoData);
                out.flush();
            }
        } else {
            // Serve generated SVG Avatar
            String etag = "W/\"cand-svg-" + candidateId + "\"";
            resp.setHeader("ETag", etag);

            String ifNoneMatch = req.getHeader("If-None-Match");
            if (etag.equals(ifNoneMatch)) {
                resp.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
                return;
            }

            byte[] svgBytes = ImageProcessingUtil.generateSvgAvatar(meta.getCandidateName());
            resp.setContentType("image/svg+xml; charset=UTF-8");
            resp.setContentLength(svgBytes.length);

            try (OutputStream out = resp.getOutputStream()) {
                out.write(svgBytes);
                out.flush();
            }
        }
    }
}
