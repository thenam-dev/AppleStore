package service.catalog;

import dao.catalog.ProductSpecificationDAO;
import dao.catalog.ProductDAO;
import model.entity.catalog.ProductSpecification;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class ProductSpecificationService {
    private static final int MAX_GROUP_LENGTH = 50;
    private static final int MAX_NAME_LENGTH = 100;
    private static final int MAX_VALUE_LENGTH = 300;

    private final ProductSpecificationDAO specificationDAO;
    private final ProductDAO productDAO;

    public ProductSpecificationService() {
        this(new ProductSpecificationDAO(), new ProductDAO());
    }

    public ProductSpecificationService(ProductSpecificationDAO specificationDAO, ProductDAO productDAO) {
        this.specificationDAO = specificationDAO;
        this.productDAO = productDAO;
    }

    public List<ProductSpecification> getSpecifications(int productId) throws SQLException {
        validateProductId(productId);
        return specificationDAO.findByProductId(productId);
    }

    public void replaceSpecifications(int productId, List<ProductSpecification> specifications) throws SQLException {
        validateProductId(productId);
        if (productDAO.findById(productId).isEmpty()) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
        }

        List<ProductSpecification> normalized = normalizeAndValidate(productId, specifications);
        specificationDAO.replaceByProductId(productId, normalized);
    }

    private List<ProductSpecification> normalizeAndValidate(int productId, List<ProductSpecification> specifications) {
        if (specifications == null || specifications.isEmpty()) {
            return Collections.emptyList();
        }

        List<ProductSpecification> normalized = new ArrayList<>();
        Set<String> specificationKeys = new HashSet<>();
        Set<Integer> displayOrders = new HashSet<>();
        for (int i = 0; i < specifications.size(); i++) {
            ProductSpecification specification = specifications.get(i);
            if (specification == null) {
                continue;
            }

            String group = trimToNull(specification.getSpecGroup());
            String name = trimToNull(specification.getSpecName());
            String value = trimToNull(specification.getSpecValue());
            Integer displayOrder = specification.getDisplayOrder();

            if (group == null && name == null && value == null && displayOrder == null) {
                continue;
            }
            if (group == null || name == null || value == null) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": nhóm, tên và giá trị không được để trống.");
            }
            if (group.length() > MAX_GROUP_LENGTH) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": nhóm không được vượt quá 50 ký tự.");
            }
            if (name.length() > MAX_NAME_LENGTH) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": tên không được vượt quá 100 ký tự.");
            }
            if (value.length() > MAX_VALUE_LENGTH) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": giá trị không được vượt quá 300 ký tự.");
            }
            if (displayOrder != null && displayOrder < 0) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": thứ tự phải là số nguyên không âm.");
            }
            if (displayOrder == null) {
                displayOrder = nextDisplayOrder(displayOrders, normalized.size() + 1);
            } else if (!displayOrders.add(displayOrder)) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": thứ tự hiển thị bị trùng.");
            }

            String specificationKey = normalizeKey(group) + "\u001F" + normalizeKey(name);
            if (!specificationKeys.add(specificationKey)) {
                throw new IllegalArgumentException("Dòng thông số " + (i + 1)
                        + ": nhóm và tên thông số bị trùng với một dòng khác.");
            }

            normalized.add(new ProductSpecification(
                    specification.getSpecId(), productId, group, name, value, displayOrder));
        }
        return normalized;
    }

    private int nextDisplayOrder(Set<Integer> usedOrders, int candidate) {
        int next = Math.max(candidate, 1);
        while (usedOrders.contains(next)) {
            next++;
        }
        usedOrders.add(next);
        return next;
    }

    private void validateProductId(int productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        }
    }

    private String trimToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeKey(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
