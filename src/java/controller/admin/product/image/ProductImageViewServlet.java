package controller.admin.product.image;

import config.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet(name = "ProductImageViewServlet", urlPatterns = "/uploads/products/*")
public class ProductImageViewServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = URLDecoder.decode(pathInfo, StandardCharsets.UTF_8);
        while (fileName.startsWith("/")) {
            fileName = fileName.substring(1);
        }
        if (fileName.isBlank() || fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path root = Paths.get(AppConfig.PERSISTENT_UPLOAD_DIR, AppConfig.PRODUCT_UPLOAD_DIR)
                .toAbsolutePath().normalize();
        Path file = root.resolve(fileName).normalize();
        if (!file.startsWith(root) || !Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(file.getFileName().toString());
        response.setContentType(contentType == null ? "application/octet-stream" : contentType);
        response.setContentLengthLong(Files.size(file));
        response.setHeader("Cache-Control", "public, max-age=2592000");
        Files.copy(file, response.getOutputStream());
    }
}
