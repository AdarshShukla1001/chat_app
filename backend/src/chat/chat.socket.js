const chatService = require("./chat.service");

function registerChatHandlers(io, socket) {
  socket.on("join_group", (groupId) => {
    socket.join(groupId);
    console.log(`Socket ${socket.id} joined group ${groupId}`);
  });

  socket.on("one_to_one_message", async ({ toUserId, content }) => {
    try {
      const fromUserId = socket.user._id; // ✅ Securely use authenticated user
      const group = await chatService.findOrCreateOneToOneGroup(
        fromUserId,
        toUserId
      );

      const message = await chatService.saveMessage(
        fromUserId,
        group._id,
        content
      );

      io.to(group._id.toString()).emit("new_message", message);
    } catch (err) {
      console.error("Error handling one_to_one_message:", err.message);
      socket.emit("error", { message: "Failed to send 1-1 message." });
    }
  });

  socket.on("group_message", async ({ groupId, content }) => {
    try {
      const fromUserId = socket.user._id; // ✅ Securely use authenticated user
      const message = await chatService.saveMessage(fromUserId, groupId, content);
      io.to(groupId).emit("new_message", message);
    } catch (err) {
      console.error("Error handling group_message:", err.message);
      socket.emit("error", { message: "Failed to send group message." });
    }
  });
}

module.exports = { registerChatHandlers };
