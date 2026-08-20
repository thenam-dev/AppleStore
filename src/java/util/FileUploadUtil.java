package util;

import config.AppConfig;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

public final class FileUploadUtil {
    public static String saveProductImage(Part part) throws IOException {
        if (part == null || part.getSize() == 0) return null;
        String originalFilename = part.getSubmittedFileName();
        if (originalFilename == null || originalFilename.isBlank()) return null;
        validateProductImage(part);

        Path uploadRoot = Paths.get(AppConfig.PERSISTENT_UPLOAD_DIR, AppConfig.PRODUCT_UPLOAD_DIR)
                .toAbsolutePath().normalize();
        Files.createDirectories(uploadRoot);
        String filename = UUID.randomUUID() + "." + getExtension(originalFilename);
        Path target = uploadRoot.resolve(filename).normalize();
        if (!target.startsWith(uploadRoot)) throw new IOException("Đường dẫn upload không hợp lệ.");
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return AppConfig.UPLOAD_DIR + "/" + AppConfig.PRODUCT_UPLOAD_DIR + "/" + filename;
    }

    public static void validateProductImage(Part part) throws IOException {
        if (part == null || part.getSize() == 0) return;
        if (part.getSize() > AppConfig.MAX_UPLOAD_SIZE_BYTES) {
            throw new IOException("Ảnh tải lên không được vượt quá 5MB.");
        }
        String filename = part.getSubmittedFileName();
        if (filename == null || filename.isBlank()) return;
        String extension = getExtension(filename);
        if (!isAllowedImage(filename) || !hasValidImageSignature(part, extension)) {
            throw new IOException("Ảnh tải lên phải có định dạng jpg, jpeg, png hoặc webp hợp lệ.");
        }
    }

    public static void deleteUploadedFile(String storedPath) {
        if (storedPath == null || !storedPath.startsWith(AppConfig.UPLOAD_DIR + "/")) return;
        String relative = storedPath.substring(AppConfig.UPLOAD_DIR.length() + 1).replace("\\", "/");
        if (relative.contains("..")) return;
        try {
            Path root = Paths.get(AppConfig.PERSISTENT_UPLOAD_DIR).toAbsolutePath().normalize();
            Path target = root.resolve(relative).normalize();
            if (target.startsWith(root)) Files.deleteIfExists(target);
        } catch (IOException ignored) {
            // Cleanup failure must not undo a successful database operation.
        }
    }

    public static boolean isAllowedImage(String filename) {
        String extension = getExtension(filename);
        for (String allowed : AppConfig.ALLOWED_IMAGE_EXTS) {
            if (allowed.equals(extension)) return true;
        }
        return false;
    }

    private static boolean hasValidImageSignature(Part part, String extension) {
        try (InputStream input = part.getInputStream()) {
            byte[] header = input.readNBytes(12);
            return switch (extension) {
                case "jpg", "jpeg" -> header.length >= 3 && header[0] == (byte) 0xFF
                        && header[1] == (byte) 0xD8 && header[2] == (byte) 0xFF;
                case "png" -> header.length >= 4 && header[0] == (byte) 0x89
                        && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47;
                case "webp" -> header.length >= 12 && header[0] == 0x52 && header[1] == 0x49
                        && header[2] == 0x46 && header[3] == 0x46 && header[8] == 0x57
                        && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50;
                default -> false;
            };
        } catch (IOException ex) {
            return false;
        }
    }

    private static String getExtension(String filename) {
        int dot = filename == null ? -1 : filename.lastIndexOf('.');
        return dot < 0 || dot == filename.length() - 1
                ? "" : filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private FileUploadUtil() { }
}
