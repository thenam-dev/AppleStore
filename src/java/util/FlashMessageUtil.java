package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/** Chuyển flash message từ session sang request để mỗi thông báo chỉ hiển thị một lần. */
public final class FlashMessageUtil {

    private static final String SUCCESS_KEY = "successMsg";
    private static final String ERROR_KEY = "errorMsg";

    private FlashMessageUtil() {
    }

    public static void moveToRequest(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }

        moveMessage(session, request, SUCCESS_KEY);
        moveMessage(session, request, ERROR_KEY);
    }

    private static void moveMessage(HttpSession session, HttpServletRequest request, String key) {
        Object message = session.getAttribute(key);
        if (message == null) {
            return;
        }

        if (request.getAttribute(key) == null) {
            request.setAttribute(key, message);
        }
        session.removeAttribute(key);
    }
}
