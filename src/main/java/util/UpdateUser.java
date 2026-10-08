package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class UpdateUser {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String pass = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "UPDATE users SET college_id = '410724562' WHERE email = 'kakashbtech24@ced.alliance.edu.in'";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    int rows = stmt.executeUpdate();
                    System.out.println("Updated rows: " + rows);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
