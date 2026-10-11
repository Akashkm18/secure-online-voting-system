package controller;

import dao.AuditLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AuditLog;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller for Security Audit Log inspection, filtering, and export.
 * URL: /admin/audit-logs
 */
@WebServlet(name = "AdminAuditLogsServlet", urlPatterns = "/admin/audit-logs")
public class AdminAuditLogsServlet extends HttpServlet {

    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String actionFilter = req.getParameter("actionFilter");
        String userSearch = req.getParameter("userSearch");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");

        // CSV export
        if ("csv".equalsIgnoreCase(req.getParameter("export"))) {
            handleCsvExport(resp, actionFilter, userSearch, startDate, endDate);
            return;
        }

        int page = 1;
        int pageSize = 20;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr.trim()));
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * pageSize;
        int totalItems = auditLogDAO.countFilteredLogs(actionFilter, userSearch, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);

        List<AuditLog> logs = auditLogDAO.getFilteredLogs(actionFilter, userSearch, startDate, endDate, offset, pageSize);

        req.setAttribute("auditLogs", logs);
        req.setAttribute("actionFilter", actionFilter != null ? actionFilter : "");
        req.setAttribute("userSearch", userSearch != null ? userSearch : "");
        req.setAttribute("startDate", startDate != null ? startDate : "");
        req.setAttribute("endDate", endDate != null ? endDate : "");
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("activeNav", "audit-logs");

        req.getRequestDispatcher("/admin/audit-logs.jsp").forward(req, resp);
    }

    private void handleCsvExport(HttpServletResponse resp, String actionFilter, String userSearch, String startDate, String endDate) throws IOException {
        List<AuditLog> list = auditLogDAO.getFilteredLogs(actionFilter, userSearch, startDate, endDate, 0, 5000);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"security-audit-logs.csv\"");
        resp.setHeader("X-Content-Type-Options", "nosniff");

        PrintWriter writer = resp.getWriter();
        writer.println("Timestamp,Event Action,User Email,Role,IP Address,Status");

        for (AuditLog log : list) {
            String safeAction = sanitizeAction(log.getAction());
            String userEmail = log.getUserEmail() != null ? log.getUserEmail() : "SYSTEM";
            String role = log.getUserRole() != null ? log.getUserRole() : "N/A";
            String ip = log.getIpAddress() != null ? log.getIpAddress() : "127.0.0.1";
            String status = log.isSuccess() ? "SUCCESS" : "FAILURE";

            writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"%n",
                    log.getCreatedAt() != null ? log.getCreatedAt().toString() : "",
                    escapeCsv(safeAction),
                    escapeCsv(userEmail),
                    escapeCsv(role),
                    escapeCsv(ip),
                    status
            );
        }
        writer.flush();
    }

    /**
     * Ensures action strings do not expose sensitive raw inputs or passwords.
     */
    private String sanitizeAction(String action) {
        if (action == null) return "UNKNOWN";
        if (action.toUpperCase().contains("PASSWORD") && action.contains("=")) {
            return action.replaceAll("(?i)password=[^&; ]*", "password=***");
        }
        return action;
    }

    private String escapeCsv(String val) {
        if (val == null) return "";
        return val.replace("\"", "\"\"");
    }
}
