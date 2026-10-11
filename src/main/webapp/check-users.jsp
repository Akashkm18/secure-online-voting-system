<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DatabaseConnection" %>
<%
    String action = request.getParameter("action");
    String message = null;

    if ("cleanVoters".equals(action)) {
        try (Connection con = DatabaseConnection.getConnection()) {
            try (PreparedStatement ps1 = con.prepareStatement("DELETE FROM votes WHERE voter_id IN (SELECT id FROM users WHERE role = 'VOTER')")) {
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement("DELETE FROM users WHERE role = 'VOTER' OR email = 'voter@voting.edu' OR college_id = 'AU-2024-CED-014'")) {
                int count = ps2.executeUpdate();
                message = "Successfully removed " + count + " voter record(s) from database.";
            }
        } catch (Exception e) {
            message = "Error cleaning voters: " + e.getMessage();
        }
    } else if ("syncAdmin".equals(action)) {
        try (Connection con = DatabaseConnection.getConnection()) {
            String adminSql = "INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, password_hash, role, is_verified, is_active) " +
                              "VALUES ('System Administrator', 'kakashbtech24@ced.alliance.edu.in', 'ADMIN-01', 'Office of Chief Election Officer', 'Election Commission', 2024, 'Faculty / Admin', " +
                              "'$2a$12$Tpnd6aLSxitfGGQy6YtZSOvbMKH.g0YY0hudAVURsnoKK7Z2kic4.', 'ADMIN', TRUE, TRUE) " +
                              "ON DUPLICATE KEY UPDATE password_hash = '$2a$12$Tpnd6aLSxitfGGQy6YtZSOvbMKH.g0YY0hudAVURsnoKK7Z2kic4.', role = 'ADMIN', is_active = TRUE";
            try (PreparedStatement ps = con.prepareStatement(adminSql)) {
                ps.executeUpdate();
                message = "Admin credentials synchronized successfully for kakashbtech24@ced.alliance.edu.in (Password: Akas@2006).";
            }
        } catch (Exception e) {
            message = "Error syncing admin: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Database Status & Management | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2.5rem; padding-bottom: 3.5rem; max-width: 900px;">
        <div style="margin-bottom: 1.5rem;">
            <h1 style="font-size: 1.6rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Live Database Inspection & Maintenance</h1>
            <p style="color: var(--text-secondary); font-size: 0.9rem;">Inspect and synchronize users and accounts currently stored in the active database</p>
        </div>

        <% if (message != null) { %>
            <div class="alert alert-info" style="margin-bottom: 1.5rem;">
                <div><%= message %></div>
            </div>
        <% } %>

        <div style="display: flex; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap;">
            <a href="check-users.jsp?action=syncAdmin" class="btn btn-primary btn-sm">
                Ensure Admin Account (kakashbtech24@ced.alliance.edu.in / Akas@2006)
            </a>
            <a href="check-users.jsp?action=cleanVoters" class="btn btn-secondary btn-sm" style="color: var(--danger);" onclick="return confirm('Wipe all voter accounts from the database?');">
                Wipe All Saved Voters
            </a>
            <a href="check-users.jsp" class="btn btn-secondary btn-sm">
                Refresh Status
            </a>
        </div>

        <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th>Email</th>
                        <th>College ID</th>
                        <th>Full Name</th>
                        <th>Role</th>
                        <th>Active</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    boolean hasRows = false;
                    try (Connection con = DatabaseConnection.getConnection();
                         Statement stmt = con.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT id, email, college_id, full_name, role, is_active FROM users ORDER BY id ASC")) {
                        while (rs.next()) {
                            hasRows = true;
                %>
                    <tr>
                        <td style="font-family: monospace;">#<%= rs.getInt("id") %></td>
                        <td style="font-weight: 600;"><%= rs.getString("email") %></td>
                        <td style="font-family: monospace;"><%= rs.getString("college_id") != null ? rs.getString("college_id") : "—" %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td>
                            <span class="badge <%= "ADMIN".equalsIgnoreCase(rs.getString("role")) ? "badge-admin" : "badge-active" %>">
                                <%= rs.getString("role") %>
                            </span>
                        </td>
                        <td><%= rs.getBoolean("is_active") ? "Yes" : "No" %></td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="6" style="color: var(--danger); padding: 1.5rem; text-align: center;">
                            Database connection error: <%= e.getMessage() %>
                        </td>
                    </tr>
                <%
                    }
                    if (!hasRows) {
                %>
                    <tr>
                        <td colspan="6" style="padding: 2.5rem; text-align: center; color: var(--text-secondary);">
                            No user records present in the database.
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

</body>
</html>
