const jwt = require("jsonwebtoken");
const { errorResponse } = require("../utils/responseHandler");
const User = require("../models/user.model");

const authMiddleware = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return errorResponse(res, "Access denied. No token provided.", 401);
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Get user from database
    const user = await User.findByPk(decoded.userId);

    if (!user) {
      return errorResponse(res, "User not found.", 401);
    }

    if (!user.isActive) {
      return errorResponse(res, "User account is inactive.", 403);
    }

    // Attach user to request object
    req.user = user;
    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return errorResponse(res, "Invalid token.", 401);
    }
    if (error.name === "TokenExpiredError") {
      return errorResponse(res, "Token expired.", 401);
    }
    return errorResponse(res, "Authentication failed.", 401);
  }
};

module.exports = authMiddleware;
