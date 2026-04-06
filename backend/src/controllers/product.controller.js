const productService = require("../services/product.service");
const { successResponse, errorResponse } = require("../utils/responseHandler");
const logger = require("../utils/logger");

class ProductController {
  async createProduct(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const product = await productService.createProduct(req.body, userId);
      return successResponse(res, product, "Product created successfully", 201);
    } catch (error) {
      logger.error("Error creating product:", error);

      // Handle duplicate barcode error
      if (error.name === "SequelizeUniqueConstraintError") {
        if (error.fields && error.fields.barcode) {
          return errorResponse(
            res,
            `A product with barcode '${req.body.barcode}' already exists. Please use a different barcode.`,
            409,
          );
        }
        if (error.fields && error.fields.clientId) {
          // This is expected for idempotency - return the existing product
          return successResponse(
            res,
            error.instance,
            "Product already exists",
            200,
          );
        }
      }

      next(error);
    }
  }

  async getAllProducts(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const { isDeleted = "false" } = req.query;
      const products = await productService.getAllProducts(
        userId,
        isDeleted === "true",
      );
      return successResponse(res, products, "Products retrieved successfully");
    } catch (error) {
      logger.error("Error getting products:", error);
      next(error);
    }
  }

  async getProductById(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const product = await productService.getProductById(
        req.params.id,
        userId,
      );
      if (!product) {
        return errorResponse(res, "Product not found", 404);
      }
      return successResponse(res, product, "Product retrieved successfully");
    } catch (error) {
      logger.error("Error getting product:", error);
      next(error);
    }
  }

  async updateProduct(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const product = await productService.updateProduct(
        req.params.id,
        userId,
        req.body,
      );
      if (!product) {
        return errorResponse(res, "Product not found", 404);
      }
      return successResponse(res, product, "Product updated successfully");
    } catch (error) {
      logger.error("Error updating product:", error);
      next(error);
    }
  }

  async deleteProduct(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const product = await productService.deleteProduct(req.params.id, userId);
      if (!product) {
        return errorResponse(res, "Product not found", 404);
      }
      return successResponse(res, null, "Product deleted successfully");
    } catch (error) {
      logger.error("Error deleting product:", error);
      next(error);
    }
  }
}

module.exports = new ProductController();
