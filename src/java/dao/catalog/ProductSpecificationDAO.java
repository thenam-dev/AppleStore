package dao.catalog;

import model.entity.catalog.ProductSpecification;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductSpecificationDAO {
    public List<ProductSpecification> findByProductId(int productId) throws SQLException {
        String sql = "SELECT spec_id, product_id, spec_group, spec_name, spec_value, display_order "
                + "FROM product_specifications WHERE product_id = ? "
                + "ORDER BY display_order ASC, spec_id ASC";

        List<ProductSpecification> specifications = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    specifications.add(mapSpecification(resultSet));
                }
            }
        }
        return specifications;
    }

    public void replaceByProductId(int productId, List<ProductSpecification> specifications) throws SQLException {
        String deleteSql = "DELETE FROM product_specifications WHERE product_id = ?";
        String insertSql = "INSERT INTO product_specifications "
                + "(product_id, spec_group, spec_name, spec_value, display_order) VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection()) {
            boolean originalAutoCommit = connection.getAutoCommit();
            try {
                connection.setAutoCommit(false);
                try (PreparedStatement deleteStatement = connection.prepareStatement(deleteSql);
                     PreparedStatement insertStatement = connection.prepareStatement(insertSql)) {
                    deleteStatement.setInt(1, productId);
                    deleteStatement.executeUpdate();

                    if (specifications != null) {
                        for (ProductSpecification specification : specifications) {
                            insertStatement.setInt(1, productId);
                            insertStatement.setString(2, specification.getSpecGroup());
                            insertStatement.setString(3, specification.getSpecName());
                            insertStatement.setString(4, specification.getSpecValue());
                            insertStatement.setInt(5, specification.getDisplayOrder());
                            insertStatement.addBatch();
                        }
                        insertStatement.executeBatch();
                    }
                }
                connection.commit();
            } catch (SQLException ex) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    ex.addSuppressed(rollbackEx);
                }
                throw ex;
            } finally {
                connection.setAutoCommit(originalAutoCommit);
            }
        }
    }

    private ProductSpecification mapSpecification(ResultSet resultSet) throws SQLException {
        return new ProductSpecification(
                resultSet.getInt("spec_id"),
                resultSet.getInt("product_id"),
                resultSet.getString("spec_group"),
                resultSet.getString("spec_name"),
                resultSet.getString("spec_value"),
                resultSet.getInt("display_order")
        );
    }
}
