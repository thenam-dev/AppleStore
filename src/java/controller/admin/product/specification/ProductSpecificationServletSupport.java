package controller.admin.product.specification;

import model.entity.catalog.Product;
import model.entity.catalog.ProductSpecification;
import service.catalog.ProductService;
import service.catalog.ProductSpecificationService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public abstract class ProductSpecificationServletSupport extends HttpServlet {
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/product-specifications/form.jsp";
    protected static final String PRODUCT_LIST_PATH = "/admin/products";
    protected static final String SPECIFICATIONS_PATH = "/admin/products/specifications";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";

    protected final ProductService productService = new ProductService();
    protected final ProductSpecificationService specificationService = new ProductSpecificationService();

    protected int parseProductId(String value) {
        try {
            int productId = Integer.parseInt(value);
            if (productId <= 0) {
                throw new NumberFormatException();
            }
            return productId;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        }
    }

    protected Product loadProduct(int productId) throws java.sql.SQLException {
        return productService.getProductById(productId);
    }

    protected List<ProductSpecification> buildSpecifications(HttpServletRequest request, int productId) {
        String[] groups = request.getParameterValues("specGroup");
        String[] names = request.getParameterValues("specName");
        String[] values = request.getParameterValues("specValue");
        String[] orders = request.getParameterValues("displayOrder");
        int rowCount = maxLength(groups, names, values, orders);
        List<ProductSpecification> specifications = new ArrayList<>();

        for (int i = 0; i < rowCount; i++) {
            String group = valueAt(groups, i);
            String name = valueAt(names, i);
            String value = valueAt(values, i);
            String order = valueAt(orders, i);
            if (group.isBlank() && name.isBlank() && value.isBlank() && order.isBlank()) {
                continue;
            }

            Integer displayOrder = null;
            if (!order.isBlank()) {
                try {
                    displayOrder = Integer.valueOf(order);
                } catch (NumberFormatException ex) {
                    throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                            + ": thứ tự phải là số nguyên.");
                }
            }
            specifications.add(new ProductSpecification(0, productId, group, name, value, displayOrder));
        }
        return specifications;
    }

    protected List<FormRow> buildFormRows(HttpServletRequest request) {
        String[] groups = request.getParameterValues("specGroup");
        String[] names = request.getParameterValues("specName");
        String[] values = request.getParameterValues("specValue");
        String[] orders = request.getParameterValues("displayOrder");
        int rowCount = Math.max(1, maxLength(groups, names, values, orders));
        List<FormRow> rows = new ArrayList<>();
        for (int i = 0; i < rowCount; i++) {
            rows.add(new FormRow(valueAt(groups, i), valueAt(names, i), valueAt(values, i), valueAt(orders, i)));
        }
        return rows;
    }

    protected List<FormRow> toFormRows(List<ProductSpecification> specifications) {
        List<FormRow> rows = new ArrayList<>();
        for (ProductSpecification specification : specifications) {
            rows.add(new FormRow(specification.getSpecGroup(), specification.getSpecName(),
                    specification.getSpecValue(), String.valueOf(specification.getDisplayOrder())));
        }
        if (rows.isEmpty()) {
            rows.add(new FormRow("", "", "", ""));
        }
        return rows;
    }

    protected void redirectWithMessage(HttpServletRequest request, HttpServletResponse response,
                                       int productId, String flashKey, String message) throws IOException {
        request.getSession().setAttribute(flashKey, message);
        response.sendRedirect(request.getContextPath() + SPECIFICATIONS_PATH + "?productId=" + productId);
    }

    protected void redirectToProductListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                    String message) throws IOException {
        request.getSession().setAttribute(FLASH_ERROR_KEY, message);
        response.sendRedirect(request.getContextPath() + PRODUCT_LIST_PATH);
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessage(request, FLASH_SUCCESS_KEY);
        moveFlashMessage(request, FLASH_ERROR_KEY);
    }

    private void moveFlashMessage(HttpServletRequest request, String key) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(key);
        if (message instanceof String) {
            request.setAttribute(key, message);
        }
        session.removeAttribute(key);
    }

    private int maxLength(String[]... arrays) {
        int max = 0;
        for (String[] array : arrays) {
            if (array != null) {
                max = Math.max(max, array.length);
            }
        }
        return max;
    }

    private String valueAt(String[] values, int index) {
        return values != null && index < values.length && values[index] != null ? values[index].trim() : "";
    }

    public static class FormRow {
        private final String specGroup;
        private final String specName;
        private final String specValue;
        private final String displayOrder;

        public FormRow(String specGroup, String specName, String specValue, String displayOrder) {
            this.specGroup = specGroup == null ? "" : specGroup;
            this.specName = specName == null ? "" : specName;
            this.specValue = specValue == null ? "" : specValue;
            this.displayOrder = displayOrder == null ? "" : displayOrder;
        }

        public String getSpecGroup() { return specGroup; }
        public String getSpecName() { return specName; }
        public String getSpecValue() { return specValue; }
        public String getDisplayOrder() { return displayOrder; }
    }
}
