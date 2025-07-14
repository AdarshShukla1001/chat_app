const express = require("express");
const router = express.Router();

const messageController = require("./controller/message.controller");
const groupController = require("./controller/group.controller");
const { protect } = require("../auth/auth.middleware");

console.log("sendMessage type:", typeof messageController.sendMessage); // should be "function"
console.log("messageController:", messageController);

console.log("createGroup type:", typeof groupController.createGroup); // should be "function"
console.log("groupController:", groupController);
// Message routes
router.post("/messages", protect, messageController.sendMessage);
router.get("/messages", protect, messageController.getMessages);
router.post(
  "/messages/:messageId/reaction",
  protect,
  messageController.reactToMessage
);

// Group routes
router.post("/groups", protect, groupController.createGroup);
router.get("/groups", protect, groupController.getMyGroups);
router.patch("/groups/:groupId", protect, groupController.updateGroup);
router.post("/groups/:groupId/leave", protect, groupController.leaveGroup);

module.exports = router;
