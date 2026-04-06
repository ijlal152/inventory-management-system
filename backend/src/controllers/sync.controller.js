const syncService = require("../services/sync.service");
const { successResponse } = require("../utils/responseHandler");
const logger = require("../utils/logger");

class SyncController {
  async bulkSync(req, res, next) {
    try {
      const userId = req.user.id; // Get user ID from authenticated user
      const { products } = req.body;

      if (!Array.isArray(products)) {
        return res.status(400).json({
          success: false,
          message: "Products must be an array",
        });
      }

      const results = await syncService.bulkSync(products, userId);
      return successResponse(res, results, "Sync completed");
    } catch (error) {
      logger.error("Error in bulk sync:", error);
      next(error);
    }
  }
}

module.exports = new SyncController();
