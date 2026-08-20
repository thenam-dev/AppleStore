package service.catalog;

import model.entity.catalog.Product;

import java.util.List;

/**
 * Cấu hình các chiều dữ liệu thật sự tạo nên một variant của từng nhóm sản phẩm.
 * Các thông số mô tả chung như chip, màn hình và camera không nằm trong cấu hình này.
 */
public class ProductVariantAttributeService {

    public List<Definition> getDefinitions(Product product) {
        if (product == null) {
            return List.of();
        }

        // Hai phụ kiện hiện tại có nghiệp vụ khác nhau dù cùng category.
        if (product.getProductId() == 11) {
            return List.of();
        }
        if (product.getProductId() == 12) {
            return List.of(Definition.COLOR);
        }

        return switch (product.getCategoryId()) {
            case 1 -> List.of(Definition.COLOR, Definition.STORAGE); // iPhone
            case 2 -> List.of(Definition.COLOR, Definition.STORAGE, Definition.CONNECTIVITY); // iPad
            case 3 -> List.of(Definition.COLOR, Definition.RAM, Definition.STORAGE); // Mac
            case 4 -> List.of(Definition.COLOR, Definition.CASE_SIZE); // Apple Watch
            case 5 -> List.of(Definition.COLOR); // AirPods
            case 6 -> List.of(Definition.STORAGE); // Apple TV
            default -> List.of();
        };
    }

    public static final class Definition {
        public static final Definition COLOR = new Definition("color", "Màu sắc");
        public static final Definition STORAGE = new Definition("storage", "Dung lượng");
        public static final Definition RAM = new Definition("ram", "RAM");
        public static final Definition CONNECTIVITY = new Definition("connectivity", "Kết nối");
        public static final Definition CASE_SIZE = new Definition("caseSize", "Kích thước vỏ");

        private final String key;
        private final String label;

        private Definition(String key, String label) {
            this.key = key;
            this.label = label;
        }

        public String getKey() {
            return key;
        }

        public String getLabel() {
            return label;
        }
    }
}
