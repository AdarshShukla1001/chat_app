const chatService = require('./chat.service');

exports.getOneToOneMessages = async (req, res) => {
  try {
    const group = await chatService.findOrCreateOneToOneGroup(req.user._id, req.params.userId);
    const messages = await chatService.getMessagesByGroup(group._id);
    res.json({ groupId: group._id, messages });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getGroupMessages = async (req, res) => {
  try {
    const messages = await chatService.getMessagesByGroup(req.params.groupId);
    res.json(messages);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createGroup = async (req, res) => {
  const { name, participants } = req.body;

  console.log("🔍 Controller Received:");
  console.log("name:", name);
  console.log("participants:", participants);
  console.log("typeof participants:", typeof participants);
  console.log("Array.isArray(participants):", Array.isArray(participants));

  try {
    const group = await chatService.createGroup(name, participants);
    res.status(201).json(group);
  } catch (err) {
    console.error("❌ Error creating group:", err);
    res.status(500).json({ message: err.message });
  }
};

