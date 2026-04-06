const jwt = require("jsonwebtoken");
const User = require("../models/user.model");
const { successResponse, errorResponse } = require("../utils/responseHandler");
const logger = require("../utils/logger");

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d",
  });
};

// Register new user
const register = async (req, res) => {
  try {
    const { username, email, password, fullName } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
      where: {
        [require("sequelize").Op.or]: [{ email }, { username }],
      },
    });

    if (existingUser) {
      if (existingUser.email === email) {
        return errorResponse(res, "Email already registered", 400);
      }
      return errorResponse(res, "Username already taken", 400);
    }

    // Create user
    const user = await User.create({
      username,
      email,
      password,
      fullName,
    });

    // Generate token
    const token = generateToken(user.id);

    logger.info(`New user registered: ${username} (${email})`);

    successResponse(
      res,
      {
        user,
        token,
      },
      "User registered successfully",
      201,
    );
  } catch (error) {
    logger.error(`Registration error: ${error.message}`);
    errorResponse(res, error.message, 500);
  }
};

// Login user
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return errorResponse(res, "Invalid email or password", 401);
    }

    // Check if account is active
    if (!user.isActive) {
      return errorResponse(
        res,
        "Account is inactive. Please contact support.",
        403,
      );
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);

    if (!isPasswordValid) {
      return errorResponse(res, "Invalid email or password", 401);
    }

    // Generate token
    const token = generateToken(user.id);

    logger.info(`User logged in: ${user.username} (${email})`);

    successResponse(
      res,
      {
        user,
        token,
      },
      "Login successful",
    );
  } catch (error) {
    logger.error(`Login error: ${error.message}`);
    errorResponse(res, error.message, 500);
  }
};

// Get current user profile
const getProfile = async (req, res) => {
  try {
    successResponse(res, req.user, "Profile retrieved successfully");
  } catch (error) {
    logger.error(`Get profile error: ${error.message}`);
    errorResponse(res, error.message, 500);
  }
};

// Update user profile
const updateProfile = async (req, res) => {
  try {
    const { fullName, username } = req.body;
    const user = req.user;

    // Check if username is taken by another user
    if (username && username !== user.username) {
      const existingUser = await User.findOne({ where: { username } });
      if (existingUser) {
        return errorResponse(res, "Username already taken", 400);
      }
      user.username = username;
    }

    if (fullName !== undefined) {
      user.fullName = fullName;
    }

    await user.save();

    logger.info(`User profile updated: ${user.username}`);

    successResponse(res, user, "Profile updated successfully");
  } catch (error) {
    logger.error(`Update profile error: ${error.message}`);
    errorResponse(res, error.message, 500);
  }
};

// Change password
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const user = req.user;

    // Verify current password
    const isPasswordValid = await user.comparePassword(currentPassword);

    if (!isPasswordValid) {
      return errorResponse(res, "Current password is incorrect", 401);
    }

    // Update password
    user.password = newPassword;
    await user.save();

    logger.info(`Password changed for user: ${user.username}`);

    successResponse(res, {}, "Password changed successfully");
  } catch (error) {
    logger.error(`Change password error: ${error.message}`);
    errorResponse(res, error.message, 500);
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  changePassword,
};
