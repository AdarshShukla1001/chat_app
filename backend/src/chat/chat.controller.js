const chatService = require('./chat.service');
const Group = require('./group.model');
const Message = require('./message.model');


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

  try {
    const group = await chatService.createGroup(name, participants);
    res.status(201).json(group);
  } catch (err) {
    console.error("❌ Error creating group:", err);
    res.status(500).json({ message: err.message });
  }
};





exports.getPaginatedMessages = async (req, res) => {
  try {
    const userId = req.user?.userId || req.user?._id || req.user?.id;
    const { groupId, page = 1, limit = 20 } = req.query;

    console.log("📩 Fetching messages for group:", {
      userId,
      groupId,
      page,
      limit,
    });

    if (!groupId) {
      return res.status(400).json({ error: "groupId is required" });
    }

    // Fetch group and validate
    const group = await Group.findById(groupId);
    if (!group) {
      console.warn("❗ Group not found");
      return res.status(404).json({ error: "Group not found" });
    }

    // Validate if user is part of the group
    const isParticipant = group.participants?.some(
      id => id.toString() === userId.toString()
    );

    if (!isParticipant) {
      console.warn("❗ User not a participant in group", {
        userId,
        participants: group.participants,
      });
      return res.status(403).json({ error: "Access denied to this group" });
    }

    // Pagination logic
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Fetch messages with optional sender and parent message data
    const messages = await Message.find({ group: groupId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate("sender", "name avatar")
      .populate("parentMessage")
      .lean();

    const totalCount = await Message.countDocuments({ group: groupId });

    // Respond with messages and pagination info
    res.json({
      messages,
      pagination: {
        total: totalCount,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(totalCount / limit),
      },
    });
  } catch (error) {
    console.error("❌ Error fetching messages:", error);
    res.status(500).json({ error: "Something went wrong" });
  }
};
