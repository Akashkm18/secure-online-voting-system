package controller;

import dao.AuditLogDAO;
import dao.CandidateDAO;
import dao.ElectionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Candidate;
import model.Election;
import model.User;
import util.CSRFUtil;
import util.ImageProcessingUtil;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

/**
 * Controller for Candidate Management (full CRUD, photo upload, validation, and storage).
 * URL: /admin/candidates
 */
@WebServlet(name = "AdminCandidatesServlet", urlPatterns = "/admin/candidates")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB buffer
        maxFileSize = 2 * 1024 * 1024,        // 2 MB max photo
        maxRequestSize = 5 * 1024 * 1024      // 5 MB max request
)
public class AdminCandidatesServlet extends HttpServlet {

    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer electionFilter = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        List<Election> allElections = electionDAO.getAllElections();

        List<Candidate> candidates;
        if (electionFilter != null) {
            candidates = candidateDAO.findByElectionId(electionFilter, false);
        } else {
            candidates = candidateDAO.getAllCandidates();
        }

        req.setAttribute("candidates", candidates);
        req.setAttribute("allElections", allElections);
        req.setAttribute("selectedElectionId", electionFilter);
        req.setAttribute("activeNav", "candidates");

        handleFlashMessages(req);

        req.getRequestDispatcher("/admin/candidates.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin privileges required.");
            return;
        }

        // Validate CSRF token from request parameter or multipart part
        if (!validateCsrf(req)) {
            session.setAttribute("flashError", "Invalid or expired security token (CSRF). Action cancelled.");
            resp.sendRedirect(req.getContextPath() + "/admin/candidates");
            return;
        }

        String action = getFormField(req, "action");
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        if ("add".equalsIgnoreCase(action)) {
            handleAdd(req, session, user, ip, ua);
        } else if ("edit".equalsIgnoreCase(action)) {
            handleEdit(req, session, user, ip, ua);
        } else if ("removePhoto".equalsIgnoreCase(action)) {
            handleRemovePhoto(req, session, user, ip, ua);
        } else if ("toggleActive".equalsIgnoreCase(action)) {
            handleToggleActive(req, session, user, ip, ua);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(req, session, user, ip, ua);
        } else {
            session.setAttribute("flashError", "Unrecognized candidate action.");
        }

        String returnElectionId = getFormField(req, "filterElectionId");
        String redirectUrl = req.getContextPath() + "/admin/candidates";
        if (returnElectionId != null && !returnElectionId.trim().isEmpty()) {
            redirectUrl += "?electionId=" + returnElectionId.trim();
        }
        resp.sendRedirect(redirectUrl);
    }

    private void handleAdd(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer electionId = ValidationUtil.parsePositiveInt(getFormField(req, "electionId"));
        String name = getFormField(req, "candidateName");
        String party = getFormField(req, "party");
        String symbol = getFormField(req, "symbol");
        String position = getFormField(req, "position");
        String bio = getFormField(req, "bio");
        String manifesto = getFormField(req, "manifesto");

        if (electionId == null || !ValidationUtil.isValidName(name)
                || !ValidationUtil.isValidPartyOrSymbol(party)
                || !ValidationUtil.isValidPartyOrSymbol(symbol)) {
            session.setAttribute("flashError", "Invalid candidate details. Please verify name, party, and symbol.");
            return;
        }

        if (bio != null && bio.length() > 500) {
            session.setAttribute("flashError", "Candidate bio cannot exceed 500 characters.");
            return;
        }

        if (manifesto != null && manifesto.length() > 1000) {
            session.setAttribute("flashError", "Candidate manifesto cannot exceed 1000 characters.");
            return;
        }

        byte[] processedPhoto = null;
        try {
            Part photoPart = req.getPart("photo");
            if (photoPart != null && photoPart.getSize() > 0) {
                byte[] rawPhoto = readPartBytes(photoPart);
                processedPhoto = ImageProcessingUtil.processCandidatePhoto(rawPhoto);
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", "Photo validation failed: " + e.getMessage());
            return;
        } catch (Exception e) {
            session.setAttribute("flashError", "Failed to process candidate photo: " + e.getMessage());
            return;
        }

        Candidate c = new Candidate();
        c.setElectionId(electionId);
        c.setCandidateName(name.trim());
        c.setParty(party.trim());
        c.setSymbol(symbol.trim());
        c.setPosition((position != null && !position.trim().isEmpty()) ? position.trim() : "Candidate");
        c.setBio(bio != null ? bio.trim() : "");
        c.setManifesto(manifesto != null ? manifesto.trim() : "");
        c.setActive(true);

        if (processedPhoto != null) {
            c.setPhotoData(processedPhoto);
            c.setPhotoType("image/png");
        }

        boolean created = candidateDAO.createCandidate(c);
        if (created) {
            auditLogDAO.log(user.getId(), "CANDIDATE_CREATED_NAME_" + c.getCandidateName() + "_ELECTION_" + electionId, ip, ua);
            session.setAttribute("flashSuccess", "Candidate \"" + c.getCandidateName() + "\" added successfully.");
        } else {
            session.setAttribute("flashError", "Failed to add candidate. Please try again.");
        }
    }

    private void handleEdit(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer candidateId = ValidationUtil.parsePositiveInt(getFormField(req, "candidateId"));
        if (candidateId == null) {
            session.setAttribute("flashError", "Invalid candidate ID.");
            return;
        }

        Candidate existing = candidateDAO.findById(candidateId);
        if (existing == null) {
            session.setAttribute("flashError", "Candidate not found.");
            return;
        }

        String name = getFormField(req, "candidateName");
        String party = getFormField(req, "party");
        String symbol = getFormField(req, "symbol");
        String position = getFormField(req, "position");
        String bio = getFormField(req, "bio");
        String manifesto = getFormField(req, "manifesto");

        if (!ValidationUtil.isValidName(name) || !ValidationUtil.isValidPartyOrSymbol(party) || !ValidationUtil.isValidPartyOrSymbol(symbol)) {
            session.setAttribute("flashError", "Invalid candidate fields. Please check formatting.");
            return;
        }

        if (bio != null && bio.length() > 500) {
            session.setAttribute("flashError", "Bio exceeds limit of 500 characters.");
            return;
        }
        if (manifesto != null && manifesto.length() > 1000) {
            session.setAttribute("flashError", "Manifesto exceeds limit of 1000 characters.");
            return;
        }

        existing.setCandidateName(name.trim());
        existing.setParty(party.trim());
        existing.setSymbol(symbol.trim());
        existing.setPosition((position != null && !position.trim().isEmpty()) ? position.trim() : "Candidate");
        existing.setBio(bio != null ? bio.trim() : "");
        existing.setManifesto(manifesto != null ? manifesto.trim() : "");

        try {
            Part photoPart = req.getPart("photo");
            if (photoPart != null && photoPart.getSize() > 0) {
                byte[] rawPhoto = readPartBytes(photoPart);
                byte[] processed = ImageProcessingUtil.processCandidatePhoto(rawPhoto);
                existing.setPhotoData(processed);
                existing.setPhotoType("image/png");
            } else {
                existing.setPhotoData(null); // Keep existing photo in updateCandidate
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", "Photo validation error: " + e.getMessage());
            return;
        } catch (Exception e) {
            session.setAttribute("flashError", "Photo processing error: " + e.getMessage());
            return;
        }

        boolean updated = candidateDAO.updateCandidate(existing);
        if (updated) {
            auditLogDAO.log(user.getId(), "CANDIDATE_UPDATED_ID_" + candidateId, ip, ua);
            session.setAttribute("flashSuccess", "Candidate updated successfully.");
        } else {
            session.setAttribute("flashError", "Failed to update candidate.");
        }
    }

    private void handleRemovePhoto(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(getFormField(req, "candidateId"));
        if (id == null) {
            session.setAttribute("flashError", "Invalid candidate ID.");
            return;
        }

        boolean removed = candidateDAO.removePhoto(id);
        if (removed) {
            auditLogDAO.log(user.getId(), "CANDIDATE_PHOTO_REMOVED_ID_" + id, ip, ua);
            session.setAttribute("flashSuccess", "Candidate photo removed. Default SVG avatar will be used.");
        } else {
            session.setAttribute("flashError", "Failed to remove candidate photo.");
        }
    }

    private void handleToggleActive(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(getFormField(req, "candidateId"));
        String activeStr = getFormField(req, "active");
        if (id == null) {
            session.setAttribute("flashError", "Invalid candidate ID.");
            return;
        }

        boolean active = "true".equalsIgnoreCase(activeStr);
        boolean ok = candidateDAO.setActiveStatus(id, active);
        if (ok) {
            auditLogDAO.log(user.getId(), "CANDIDATE_STATUS_TOGGLED_ID_" + id + "_TO_" + active, ip, ua);
            session.setAttribute("flashSuccess", "Candidate status changed successfully.");
        } else {
            session.setAttribute("flashError", "Failed to update candidate status.");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(getFormField(req, "candidateId"));
        if (id == null) {
            session.setAttribute("flashError", "Invalid candidate ID.");
            return;
        }

        if (candidateDAO.hasVotes(id)) {
            session.setAttribute("flashError", "Cannot delete candidate who has already received votes in an active/completed election.");
            return;
        }

        boolean deleted = candidateDAO.deleteCandidate(id);
        if (deleted) {
            auditLogDAO.log(user.getId(), "CANDIDATE_DELETED_ID_" + id, ip, ua);
            session.setAttribute("flashSuccess", "Candidate removed successfully.");
        } else {
            session.setAttribute("flashError", "Failed to delete candidate.");
        }
    }

    private boolean validateCsrf(HttpServletRequest req) {
        String token = getFormField(req, CSRFUtil.CSRF_PARAM_NAME);
        if (token == null || token.trim().isEmpty()) {
            token = req.getHeader("X-CSRF-TOKEN");
        }
        if (token == null || token.trim().isEmpty()) {
            String qs = req.getQueryString();
            if (qs != null && qs.contains(CSRFUtil.CSRF_PARAM_NAME + "=")) {
                for (String param : qs.split("&")) {
                    String[] pair = param.split("=", 2);
                    if (pair.length == 2 && CSRFUtil.CSRF_PARAM_NAME.equals(pair[0])) {
                        token = java.net.URLDecoder.decode(pair[1], java.nio.charset.StandardCharsets.UTF_8);
                        break;
                    }
                }
            }
        }

        HttpSession session = req.getSession(false);
        if (session == null || token == null) return false;
        String sessionToken = (String) session.getAttribute(CSRFUtil.CSRF_SESSION_ATTR);
        if (sessionToken == null) return false;

        return java.security.MessageDigest.isEqual(
                sessionToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                token.getBytes(java.nio.charset.StandardCharsets.UTF_8)
        );
    }

    private String getFormField(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        if (val != null) return val;
        try {
            Part part = req.getPart(name);
            if (part != null) {
                try (InputStream is = part.getInputStream()) {
                    return new String(is.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8).trim();
                }
            }
        } catch (Exception ignored) {}
        return null;
    }

    private byte[] readPartBytes(Part part) throws IOException {
        try (InputStream is = part.getInputStream();
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = is.read(buf)) != -1) {
                baos.write(buf, 0, n);
            }
            return baos.toByteArray();
        }
    }

    private void handleFlashMessages(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String success = (String) session.getAttribute("flashSuccess");
            if (success != null) {
                req.setAttribute("flashSuccess", success);
                session.removeAttribute("flashSuccess");
            }
            String error = (String) session.getAttribute("flashError");
            if (error != null) {
                req.setAttribute("flashError", error);
                session.removeAttribute("flashError");
            }
        }
    }
}
