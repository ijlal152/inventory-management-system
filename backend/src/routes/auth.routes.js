const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");
const authMiddleware = require("../middleware/auth.middleware");
const { body } = require("express-validator");
const { validate } = require("../validators/validate");

// Validation rules
const registerValidation = [
  body("username")
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage("Username must be between 3 and 50 characters")
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage("Username can only contain letters, numbers, and underscores"),
  body("email")
    .trim()
    .isEmail()
    .withMessage("Must be a valid email address")
    .normalizeEmail(),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters"),
  body("fullName")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Full name must not exceed 100 characters"),
  validate,
];

const loginValidation = [
  body("email")
    .trim()
    .isEmail()
    .withMessage("Must be a valid email address")
    .normalizeEmail(),
  body("password").notEmpty().withMessage("Password is required"),
  validate,
];

const updateProfileValidation = [
  body("username")
    .optional()
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage("Username must be between 3 and 50 characters")
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage("Username can only contain letters, numbers, and underscores"),
  body("fullName")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Full name must not exceed 100 characters"),
  validate,
];

const changePasswordValidation = [
  body("currentPassword")
    .notEmpty()
    .withMessage("Current password is required"),
  body("newPassword")
    .isLength({ min: 6 })
    .withMessage("New password must be at least 6 characters"),
  validate,
];

// Public routes
router.post("/register", registerValidation, authController.register);
router.post("/login", loginValidation, authController.login);

// Protected routes (require authentication)
router.get("/profile", authMiddleware, authController.getProfile);
router.put(
  "/profile",
  authMiddleware,
  updateProfileValidation,
  authController.updateProfile,
);
router.post(
  "/change-password",
  authMiddleware,
  changePasswordValidation,
  authController.changePassword,
);

module.exports = router;
