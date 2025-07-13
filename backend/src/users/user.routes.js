const express = require("express");
const router = express.Router();
const userController = require("./user.controller");
const { protect } = require("../auth/auth.middleware");

router.get("/me", protect, userController.getMe);
router.put("/me", protect, userController.updateMe);
router.post("/upload-avatar", protect, userController.uploadAvatar);

module.exports = router;
