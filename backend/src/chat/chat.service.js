const Group = require("./group.model");
const Message = require("./message.model");
const User = require("../users/user.model");

const mongoose = require('mongoose');

async function findOrCreateOneToOneGroup(userA, userB) {
  const sorted = [userA.toString(), userB.toString()].sort();
  let group = await Group.findOne({
    isGroup: false,
    participants: { $all: sorted, $size: 2 },
  });

  if (!group) {
    group = await Group.create({
      isGroup: false,
      participants: sorted,
    });
  }

  return group;
}

async function createGroup(name, participants) {
  // Step 1: Handle stringified JSON arrays
  if (typeof participants === "string") {
    try {
      const fixed = participants.replace(/'/g, '"');
      participants = JSON.parse(fixed);
    } catch {
      throw new Error(
        "Invalid participants format. Must be a valid JSON array."
      );
    }
  }

  // Step 2: Check if it's an array
  if (!Array.isArray(participants)) {
    throw new Error("Participants must be an array.");
  }

  // Step 3: Validate each ObjectId
  const invalidIds = participants.filter(
    (id) => !mongoose.Types.ObjectId.isValid(id)
  );
  if (invalidIds.length > 0) {
    throw new Error(`Invalid ObjectId(s): ${invalidIds.join(", ")}`);
  }

  const participantIds = participants.map(
    (id) => new mongoose.Types.ObjectId(id)
  );

  // Step 4 (Optional but recommended): Check if all users exist
  const existingUsers = await User.find({ _id: { $in: participantIds } });
  if (existingUsers.length !== participantIds.length) {
    const foundIds = existingUsers.map((u) => u._id.toString());
    const missing = participantIds.filter(
      (id) => !foundIds.includes(id.toString())
    );
    throw new Error(`User(s) not found for ID(s): ${missing.join(", ")}`);
  }
  return await Group.create({ isGroup: true, name, participants });
}

async function saveMessage(sender, groupId, content) {
  return await Message.create({ sender, group: groupId, content });
}

async function getMessagesByGroup(groupId) {
  return await Message.find({ group: groupId })
    .sort({ createdAt: 1 })
    .populate("sender", "name email");
}

module.exports = {
  findOrCreateOneToOneGroup,
  createGroup,
  saveMessage,
  getMessagesByGroup,
};
