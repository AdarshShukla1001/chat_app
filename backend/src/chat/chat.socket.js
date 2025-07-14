// src/chat/chat.socket.js
const chatService = require('./chat.service');
const Group = require('./group.model');
const Message = require('./message.model');

function registerChatHandlers(io, socket) {
  if (!socket.user) {
    console.warn('❌ Rejected unauthenticated socket');
    socket.disconnect();
    return;
  }

  const userId = socket.user._id.toString();
  socket.join(userId); // Join personal room for direct emits

  // Optionally join all groups the user is a part of
  Group.find({ participants: userId }, '_id').then(groups => {
    groups.forEach(g => socket.join(g._id.toString()));
    console.log(`🔗 Joined ${groups.length} group rooms for user ${userId}`);
  });

  // 🔹 Join Group Room
  socket.on('join_group', (groupId) => {
    socket.join(groupId);
    console.log(`✅ Socket ${socket.id} joined group ${groupId}`);
  });

  // 🔹 One-to-One Message
  socket.on('one_to_one_message', async ({ toUserId, content, parentMessage }) => {
    try {
      const fromUserId = socket.user._id;
      const group = await chatService.findOrCreateOneToOneGroup(fromUserId, toUserId);

      const message = await chatService.saveMessage(fromUserId, group._id, content, parentMessage);
      await Group.findByIdAndUpdate(group._id, { lastMessage: message._id });

      io.to(fromUserId.toString()).emit('new_message', message);
      io.to(toUserId.toString()).emit('new_message', message);
    } catch (err) {
      console.error('❌ Error in one_to_one_message:', err.message);
      socket.emit('error', { message: 'Failed to send 1-to-1 message.' });
    }
  });

  // 🔹 Group Message
  socket.on('group_message', async ({ groupId, content, parentMessage }) => {
    try {
      const fromUserId = socket.user._id;
      const group = await Group.findById(groupId);

      if (!group || !group.participants.includes(fromUserId)) {
        return socket.emit('error', { message: 'Not a participant of the group.' });
      }

      const message = await chatService.saveMessage(fromUserId, groupId, content, parentMessage);
      await Group.findByIdAndUpdate(groupId, { lastMessage: message._id });

      group.participants.forEach(uid => {
        io.to(uid.toString()).emit('new_message', message);
      });
    } catch (err) {
      console.error('❌ Error in group_message:', err.message);
      socket.emit('error', { message: 'Failed to send group message.' });
    }
  });

  // 🔹 React to Message
  socket.on('react_to_message', async ({ messageId, emoji }) => {
    try {
      const userId = socket.user._id;
      await Message.updateOne(
        { _id: messageId },
        { $addToSet: { [`reactions.${userId}`]: emoji } }
      );

      const updatedMessage = await Message.findById(messageId);
      const group = await Group.findById(updatedMessage.group);

      group.participants.forEach(uid => {
        io.to(uid.toString()).emit('message_reacted', {
          messageId,
          userId,
          emoji,
        });
      });
    } catch (err) {
      console.error('❌ Error in react_to_message:', err.message);
      socket.emit('error', { message: 'Failed to react to message.' });
    }
  });
}

module.exports = { registerChatHandlers };
