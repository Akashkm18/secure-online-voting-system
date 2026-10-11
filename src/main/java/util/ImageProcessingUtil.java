package util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Utility for verifying, center-cropping, resizing, and stripping metadata from candidate photos,
 * as well as generating default initial SVG avatars.
 */
public class ImageProcessingUtil {

    public static final int TARGET_WIDTH = 400;
    public static final int TARGET_HEIGHT = 400;
    public static final long MAX_FILE_SIZE = 2 * 1024 * 1024; // 2 MB

    private static final String[] PALETTE = {
            "#1e40af", "#0284c7", "#0d9488", "#059669",
            "#4338ca", "#6d28d9", "#b45309", "#be123c"
    };

    /**
     * Inspects magic bytes to ensure file is strictly JPEG or PNG.
     * Rejects executables, scripts, gifs, text, etc.
     */
    public static boolean hasValidMagicBytes(byte[] bytes) {
        if (bytes == null || bytes.length < 8) {
            return false;
        }

        // JPEG: FF D8 FF
        boolean isJpeg = (bytes[0] == (byte) 0xFF && bytes[1] == (byte) 0xD8 && bytes[2] == (byte) 0xFF);
        if (isJpeg) return true;

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        boolean isPng = (bytes[0] == (byte) 0x89 && bytes[1] == (byte) 0x50 &&
                         bytes[2] == (byte) 0x4E && bytes[3] == (byte) 0x47 &&
                         bytes[4] == (byte) 0x0D && bytes[5] == (byte) 0x0A &&
                         bytes[6] == (byte) 0x1A && bytes[7] == (byte) 0x0A);
        return isPng;
    }

    /**
     * Validates and processes candidate photo:
     * 1. Checks size <= 2MB
     * 2. Checks magic bytes for JPEG / PNG
     * 3. Reads with ImageIO (rejects corrupt / non-images)
     * 4. Center-crops to square and resizes to 400x400
     * 5. Strips all EXIF / metadata
     *
     * @return clean processed PNG bytes
     * @throws IllegalArgumentException if validation fails
     */
    public static byte[] processCandidatePhoto(byte[] rawBytes, String contentType) throws IOException, IllegalArgumentException {
        if (contentType != null && !contentType.trim().isEmpty()) {
            String ct = contentType.toLowerCase().trim();
            if (!ct.contains("image/jpeg") && !ct.contains("image/jpg") && !ct.contains("image/png")) {
                throw new IllegalArgumentException("Only JPEG and PNG images are supported. Received: " + contentType);
            }
        }
        return processCandidatePhoto(rawBytes);
    }

    public static byte[] processCandidatePhoto(byte[] rawBytes) throws IOException, IllegalArgumentException {
        if (rawBytes == null || rawBytes.length == 0) {
            throw new IllegalArgumentException("No photo data provided.");
        }
        if (rawBytes.length > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("Photo exceeds the maximum allowed size of 2 MB.");
        }
        if (!hasValidMagicBytes(rawBytes)) {
            throw new IllegalArgumentException("Invalid file format. Only real JPEG or PNG images are accepted.");
        }

        BufferedImage original = ImageIO.read(new ByteArrayInputStream(rawBytes));
        if (original == null) {
            throw new IllegalArgumentException("Corrupted or invalid image file. Unable to decode image content.");
        }

        int origW = original.getWidth();
        int origH = original.getHeight();
        if (origW <= 0 || origH <= 0) {
            throw new IllegalArgumentException("Invalid image dimensions.");
        }

        // Square center crop
        int side = Math.min(origW, origH);
        int cropX = (origW - side) / 2;
        int cropY = (origH - side) / 2;
        BufferedImage cropped = original.getSubimage(cropX, cropY, side, side);

        // High quality resize to 400x400
        BufferedImage resized = new BufferedImage(TARGET_WIDTH, TARGET_HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = resized.createGraphics();
        try {
            g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g2d.drawImage(cropped, 0, 0, TARGET_WIDTH, TARGET_HEIGHT, null);
        } finally {
            g2d.dispose();
        }

        // Re-encoding directly to PNG natively strips metadata
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(resized, "png", baos);
        return baos.toByteArray();
    }

    /**
     * Generates an SVG avatar displaying candidate initials on a modern colored circle.
     */
    public static byte[] generateSvgAvatar(String name) {
        String initials = extractInitials(name);
        String bgColor = pickColor(name);

        String svg = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"400\" viewBox=\"0 0 400 400\">\n" +
                "  <defs>\n" +
                "    <linearGradient id=\"avatarGrad\" x1=\"0%\" y1=\"0%\" x2=\"100%\" y2=\"100%\">\n" +
                "      <stop offset=\"0%\" stop-color=\"" + bgColor + "\" />\n" +
                "      <stop offset=\"100%\" stop-color=\"#0f172a\" stop-opacity=\"0.85\" />\n" +
                "    </linearGradient>\n" +
                "  </defs>\n" +
                "  <rect width=\"400\" height=\"400\" rx=\"200\" fill=\"url(#avatarGrad)\"/>\n" +
                "  <text x=\"200\" y=\"225\" font-family=\"system-ui, -apple-system, sans-serif\" font-size=\"140\" " +
                "font-weight=\"700\" fill=\"#ffffff\" text-anchor=\"middle\" dominant-baseline=\"middle\" letter-spacing=\"2\">" +
                initials +
                "</text>\n" +
                "</svg>";

        return svg.getBytes(StandardCharsets.UTF_8);
    }

    private static String extractInitials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "AU";
        }
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) {
            String p = parts[0];
            return p.length() >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
        }
        String first = parts[0];
        String last = parts[parts.length - 1];
        String i1 = first.isEmpty() ? "" : first.substring(0, 1).toUpperCase();
        String i2 = last.isEmpty() ? "" : last.substring(0, 1).toUpperCase();
        return (i1 + i2).isEmpty() ? "AU" : (i1 + i2);
    }

    private static String pickColor(String text) {
        if (text == null || text.trim().isEmpty()) {
            return PALETTE[0];
        }
        int hash = Math.abs(text.trim().hashCode());
        return PALETTE[hash % PALETTE.length];
    }
}
