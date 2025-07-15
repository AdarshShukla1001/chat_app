const chatService = require("./chat.service");
const Group = require("./group.model");
const Message = require("./message.model");

function registerChatHandlers(io, socket) {
  if (!socket.user) {
    console.warn("❌ Rejected unauthenticated socket");
    socket.disconnect();
    return;
  }

  const userId = socket.user._id.toString();
  socket.join(userId); // Join personal room

  // Automatically join all group rooms user is part of
  Group.find({ participants: userId }, "_id").then((groups) => {
    groups.forEach((g) => socket.join(g._id.toString()));
    console.log(`🔗 Socket ${socket.id} joined ${groups.length} group rooms`);
  });

  // 🔹 Join Group Room Manually
  socket.on("join_group", (groupId) => {
    socket.join(groupId);
    console.log(`✅ Socket ${socket.id} joined group ${groupId}`);
  });

  // 🔹 Combined Message Handler (for group & 1-to-1)
  socket.on("send_message", async ({ groupId, content, parentMessage }) => {
    try {
      const fromUserId = socket.user._id;
      if (!content || !groupId) {
        return socket.emit("error", { message: "Missing content or groupId" });
      }

      const group = await Group.findById(groupId);
      if (!group || !group.participants.includes(fromUserId)) {
        return socket.emit("error", {
          message: "Not a participant of the group.",
        });
      }

      const message = await chatService.saveMessage(
        fromUserId,
        groupId,
        content,
        parentMessage
      );
      await Group.findByIdAndUpdate(groupId, { lastMessage: message._id });

      console.log(
        `📨 Message sent by ${fromUserId} to group ${groupId}: "${content}"`
      );
      const plainMessage = message.toObject();
      plainMessage.sender = {
        _id: socket.user._id,
        name: socket.user.name,
        email: socket.user.email,
        avatar: socket.user.avatar, // add any additional fields you want
      };

      // Emit to all participants
      group.participants.forEach((uid) => {
        io.to(uid.toString()).emit("new_message", plainMessage);
        console.log(`➡️ Emitted new_message to user ${uid}`);
      });
    } catch (err) {
      console.error("❌ Error in send_message:", err.message);
      socket.emit("error", { message: "Failed to send message." });
    }
  });

  // 🔹 React to Message
  socket.on("react_to_message", async ({ messageId, emoji }) => {
    try {
      const userId = socket.user._id;
      await Message.updateOne(
        { _id: messageId },
        { $addToSet: { [`reactions.${userId}`]: emoji } }
      );

      const updatedMessage = await Message.findById(messageId).populate(
        "sender"
      );

      const group = await Group.findById(updatedMessage.group);
      group.participants.forEach((uid) => {
        io.to(uid.toString()).emit("message_reacted", {
          messageId,
          userId,
          emoji,
          updatedMessage, // ✅ emit updated message too
        });
      });
    } catch (err) {
      console.error("❌ Error in react_to_message:", err.message);
      socket.emit("error", { message: "Failed to react to message." });
    }
  });
}

module.exports = { registerChatHandlers };
