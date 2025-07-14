const Group = require("../group.model");
const chatService = require("../chat.service");

exports.createGroup = async (req, res) => {
  const { name, participants, isGroup = true } = req.body;
  try {
    if (!isGroup && participants.length === 2) {
      const existing = await Group.findOne({
        isGroup: false,
        participants: { $all: participants, $size: 2 },
      });
      if (existing) return res.status(200).json(existing);
    }

    const group = await chatService.createGroup(
      name,
      participants,
      req.user._id,
      isGroup
    );
    res.status(201).json(group);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getMyGroups = async (req, res) => {
  try {
    const groups = await Group.find({ participants: req.user._id }).sort({
      updatedAt: -1,
    });
    res.json(groups);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateGroup = async (req, res) => {
  const { groupId } = req.params;
  const { name, image, description } = req.body;

  try {
    const group = await Group.findById(groupId);
    if (!group) return res.status(404).json({ message: "Group not found" });

    if (!group.admins.includes(req.user._id)) {
      return res.status(403).json({ message: "Only admins can update group" });
    }

    if (name) group.name = name;
    if (image) group.image = image;
    if (description) group.description = description;

    await group.save();
    res.json(group);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.leaveGroup = async (req, res) => {
  const { groupId } = req.params;
  const userId = req.user._id;

  try {
    const group = await Group.findById(groupId);
    if (!group) return res.status(404).json({ message: "Group not found" });

    group.participants = group.participants.filter(
      (id) => id.toString() !== userId.toString()
    );
    group.admins = group.admins.filter(
      (id) => id.toString() !== userId.toString()
    );

    await group.save();
    res.json({ message: "Left group successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
