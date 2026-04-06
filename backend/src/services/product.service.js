const Product = require("../models/product.model");
const { Op } = require("sequelize");

class ProductService {
  async createProduct(productData, userId) {
    // Check if product with clientId already exists for this user
    const existing = await Product.findOne({
      where: {
        clientId: productData.clientId,
        userId: userId,
      },
    });

    if (existing) {
      return existing; // Return existing to maintain idempotency
    }

    // Convert empty barcode to null to avoid unique constraint issues
    if (productData.barcode === "") {
      productData.barcode = null;
    }

    // Add userId to product data
    const product = await Product.create({
      ...productData,
      userId: userId,
    });
    return product;
  }

  async getAllProducts(userId, includeDeleted = false) {
    const whereClause = {
      userId: userId,
      ...(includeDeleted ? {} : { isDeleted: false }),
    };
    return await Product.findAll({
      where: whereClause,
      order: [["createdAt", "DESC"]],
    });
  }

  async getProductById(id, userId) {
    return await Product.findOne({
      where: {
        id: id,
        userId: userId,
      },
    });
  }

  async updateProduct(id, userId, updates) {
    const product = await Product.findOne({
      where: {
        id: id,
        userId: userId,
      },
    });

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

  async deleteProduct(id, userId) {
    const product = await Product.findOne({
      where: {
        id: id,
        userId: userId,
      },
    });

    if (!product) {
      return null;
    }

    // Soft delete
    await product.update({ isDeleted: true });
    return product;
  }

  async findByClientId(clientId, userId) {
    return await Product.findOne({
      where: {
        clientId,
        userId: userId,
      },
    });
  }
}

module.exports = new ProductService();
