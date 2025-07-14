const Message = require("../message.model");
const Group = require("../group.model");
const chatService = require("../chat.service");

exports.sendMessage = async (req, res) => {
  try {
    const { groupId, content, parentMessage } = req.body;
    const userId = req.user._id;

    const group = await Group.findById(groupId);
    if (!group || !group.participants.includes(userId)) {
      return res
        .status(403)
        .json({ message: "Not a participant of the group" });
    }

    const message = await chatService.saveMessage(
      userId,
      groupId,
      content,
      parentMessage
    );

    group.lastMessage = message._id;
    await group.save();

    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.reactToMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;

    await Message.updateOne(
      { _id: messageId },
      { $addToSet: { [`reactions.${userId}`]: emoji } }
    );

    const updatedMessage = await Message.findById(messageId);
    res.json(updatedMessage);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getMessages = async (req, res) => {
  const { groupId, userId } = req.query;

  try {
    let group;
    if (groupId) {
      group = await Group.findById(groupId);
    } else if (userId) {
      group = await chatService.findOrCreateOneToOneGroup(req.user._id, userId);
    }

    if (!group) return res.status(404).json({ message: "Group not found" });

    const messages = await chatService.getMessagesByGroup(group._id);
    res.json({ groupId: group._id, messages });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
