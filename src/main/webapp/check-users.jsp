<%@ page import="java.sql.*" %>
<%@ page import="util.DatabaseConnection" %>
<%
    out.println("<h3>Users in Database:</h3>");
    out.println("<table border='1'><tr><th>ID</th><th>Email</th><th>College ID</th><th>Name</th></tr>");
    try (Connection con = DatabaseConnection.getConnection();
         Statement stmt = con.createStatement();
         ResultSet rs = stmt.executeQuery("SELECT id, email, college_id, full_name FROM users")) {
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("id") + "</td>");
            out.println("<td>" + rs.getString("email") + "</td>");
            out.println("<td>" + rs.getString("college_id") + "</td>");
            out.println("<td>" + rs.getString("full_name") + "</td>");
            out.println("</tr>");
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
    }
    out.println("</table>");
%>
