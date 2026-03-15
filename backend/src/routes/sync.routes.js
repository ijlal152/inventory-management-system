const express = require("express");
const syncController = require("../controllers/sync.controller");

const router = express.Router();

router.post("/sync", syncController.bulkSync);

module.exports = router;
