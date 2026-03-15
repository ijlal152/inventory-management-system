const Product = require("../models/product.model");
const { Op } = require("sequelize");

class ProductService {
  async createProduct(productData) {
    // Check if product with clientId already exists (prevent duplicates)
    const existing = await Product.findOne({
      where: { clientId: productData.clientId },
    });

    if (existing) {
      return existing; // Return existing to maintain idempotency
    }

    // Convert empty barcode to null to avoid unique constraint issues
    if (productData.barcode === "") {
      productData.barcode = null;
    }

    const product = await Product.create(productData);
    return product;
  }

  async getAllProducts(includeDeleted = false) {
    const whereClause = includeDeleted ? {} : { isDeleted: false };
    return await Product.findAll({
      where: whereClause,
      order: [["createdAt", "DESC"]],
    });
  }

  async getProductById(id) {
    return await Product.findByPk(id);
  }

  async updateProduct(id, updates) {
    const product = await Product.findByPk(id);
    if (!product) {
      return null;
    }

    // Convert empty barcode to null to avoid unique constraint issues
    if (updates.barcode === "") {
      updates.barcode = null;
    }

    await product.update(updates);
    return product;
  }

  async deleteProduct(id) {
    const product = await Product.findByPk(id);
    if (!product) {
      return null;
    }

    // Soft delete
    await product.update({ isDeleted: true });
    return product;
  }

  async findByClientId(clientId) {
    return await Product.findOne({ where: { clientId } });
  }
}

module.exports = new ProductService();
