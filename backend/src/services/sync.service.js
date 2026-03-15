const productService = require("./product.service");
const logger = require("../utils/logger");

class SyncService {
  async bulkSync(products) {
    const results = [];
    const errors = [];

    for (const item of products) {
      try {
        const { clientId, serverId, action, data } = item;

        let result;
        switch (action) {
          case "create":
            result = await productService.createProduct({
              ...data,
              clientId,
            });
            results.push({
              clientId,
              serverId: result.id.toString(),
              status: "success",
            });
            break;

          case "update":
            if (!serverId) {
              throw new Error("serverId required for update");
            }
            result = await productService.updateProduct(serverId, data);
            if (!result) {
              throw new Error("Product not found");
            }
            results.push({
              clientId,
              serverId,
              status: "success",
            });
            break;

          case "delete":
            if (!serverId) {
              throw new Error("serverId required for delete");
            }
            result = await productService.deleteProduct(serverId);
            if (!result) {
              throw new Error("Product not found");
            }
            results.push({
              clientId,
              status: "success",
            });
            break;

          default:
            throw new Error(`Unknown action: ${action}`);
        }
      } catch (error) {
        logger.error(`Sync error for item:`, error);
        errors.push({
          clientId: item.clientId,
          error: error.message,
        });
      }
    }

    return {
      results,
      errors,
      summary: {
        total: products.length,
        success: results.length,
        failed: errors.length,
      },
    };
  }
}

module.exports = new SyncService();
