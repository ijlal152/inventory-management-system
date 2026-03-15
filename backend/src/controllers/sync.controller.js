const syncService = require("../services/sync.service");
const { successResponse } = require("../utils/responseHandler");
const logger = require("../utils/logger");

class SyncController {
  async bulkSync(req, res, next) {
    try {
      const { products } = req.body;

      if (!Array.isArray(products)) {
        return res.status(400).json({
          success: false,
          message: "Products must be an array",
        });
      }

      const results = await syncService.bulkSync(products);
      return successResponse(res, results, "Sync completed");
    } catch (error) {
      logger.error("Error in bulk sync:", error);
      next(error);
    }
  }
}

module.exports = new SyncController();
