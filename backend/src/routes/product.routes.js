const express = require("express");
const productController = require("../controllers/product.controller");
const { validateProduct } = require("../validators/product.validator");

const router = express.Router();

router.post("/", validateProduct, productController.createProduct);
router.get("/", productController.getAllProducts);
router.get("/:id", productController.getProductById);
router.put("/:id", validateProduct, productController.updateProduct);
router.delete("/:id", productController.deleteProduct);

module.exports = router;
