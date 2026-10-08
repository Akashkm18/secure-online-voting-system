package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

@WebServlet("/api/id-card/analyze")
public class OcrServlet extends HttpServlet {
    
    // Configured Backend Gemini API Key (Placeholder for GitHub Push)
    private static final String GEMINI_API_KEY = "YOUR_API_KEY_HERE";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Read JSON payload from frontend
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        
        String requestBody = sb.toString();
        // Extremely simple JSON parsing to get base64Image
        String base64Image = "";
        int imageIndex = requestBody.indexOf("\"base64Image\":\"");
        if (imageIndex != -1) {
            int startIndex = imageIndex + 15;
            int endIndex = requestBody.indexOf("\"", startIndex);
            if (endIndex != -1) {
                base64Image = requestBody.substring(startIndex, endIndex);
            }
        }
        
        if (base64Image.isEmpty()) {
            response.setStatus(400);
            response.getWriter().write("{\"success\":false,\"error\":\"No base64Image provided\",\"stage\":\"backend_validation\"}");
            return;
        }

        try {
            // Forward to Gemini Vision API securely from backend
            String geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=" + GEMINI_API_KEY;
            URL url = new URL(geminiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            
            String prompt = "You are a universal Student ID Card parser. Analyze this image and extract the following fields exactly. " +
                            "Do not make up any information. If a field is not found, use the exact string \"Not detected\". " +
                            "Return ONLY a valid JSON object without any markdown formatting, backticks, or extra text. " +
                            "Expected JSON format: " +
                            "{ \"name\": \"Student Name\", \"studentId\": \"Registration Number or ID\", " +
                            "\"college\": \"College or University Name\", \"program\": \"Degree and Program Name\", \"joinedYear\": \"Admission Year\" }";
                            
            String geminiPayload = "{" +
                "\"contents\": [{" +
                    "\"parts\": [" +
                        "{ \"text\": \"" + prompt.replace("\"", "\\\"") + "\" }," +
                        "{" +
                            "\"inline_data\": {" +
                                "\"mime_type\": \"image/jpeg\"," +
                                "\"data\": \"" + base64Image + "\"" +
                            "}" +
                        "}" +
                    "]" +
                "}]," +
                "\"generationConfig\": {" +
                    "\"temperature\": 0.1," +
                    "\"response_mime_type\": \"application/json\"" +
                "}" +
            "}";
            
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = geminiPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            int status = conn.getResponseCode();
            InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();
            
            StringBuilder geminiResponse = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    geminiResponse.append(line.trim());
                }
            }
            
            if (status >= 200 && status < 300) {
                // Parse Gemini response text manually to avoid heavy dependencies
                String resp = geminiResponse.toString();
                int textStart = resp.indexOf("\"text\": \"");
                if (textStart != -1) {
                    textStart += 9;
                    int textEnd = resp.indexOf("\"", textStart);
                    // Handle escaped quotes inside the JSON string
                    while (textEnd != -1 && resp.charAt(textEnd - 1) == '\\') {
                        textEnd = resp.indexOf("\"", textEnd + 1);
                    }
                    if (textEnd != -1) {
                        String jsonContent = resp.substring(textStart, textEnd)
                                                .replace("\\n", "\n")
                                                .replace("\\\"", "\"");
                                                
                        if (jsonContent.startsWith("```json")) {
                            jsonContent = jsonContent.substring(7);
                        }
                        if (jsonContent.endsWith("```")) {
                            jsonContent = jsonContent.substring(0, jsonContent.length() - 3);
                        }
                        
                        // Successfully extracted the JSON from Gemini, wrap it and send to frontend
                        response.getWriter().write("{\"success\":true,\"data\":" + jsonContent + "}");
                        return;
                    }
                }
                // Fallback if parsing failed
                response.setStatus(500);
                response.getWriter().write("{\"success\":false,\"error\":\"Failed to parse Gemini response\",\"stage\":\"backend_parsing\"}");
            } else {
                response.setStatus(status);
                // Return exactly what Gemini failed with, properly escaped
                String safeError = geminiResponse.toString().replace("\"", "\\\"");
                response.getWriter().write("{\"success\":false,\"error\":\"" + safeError + "\",\"stage\":\"gemini_api\"}");
            }
            
        } catch (Exception e) {
            response.setStatus(500);
            response.getWriter().write("{\"success\":false,\"error\":\"Backend Exception: " + e.getMessage() + "\",\"stage\":\"backend_exception\"}");
            e.printStackTrace();
        }
    }
}
