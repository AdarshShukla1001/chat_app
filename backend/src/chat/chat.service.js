const Group = require("./group.model");
const Message = require("./message.model");

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

async function createGroup(name, participants, createdBy, isGroup = true) {
  return await Group.create({
    isGroup,
    name,
    participants,
    createdBy, // ✅ Assign the creator
    admins: [createdBy], // Optional: add creator as admin
  });
}

async function saveMessage(sender, groupId, content) {
  const message = await Message.create({ sender, group: groupId, content });
  await Group.findByIdAndUpdate(groupId, { lastMessage: message._id });
  return message;
}

async function getMessagesByGroup(groupId) {
  return await Message.find({ group: groupId })
    .sort({ createdAt: 1 })
    .populate("sender", "name email");
}

async function isParticipant(groupId, userId) {
  const group = await Group.findOne({ _id: groupId, participants: userId });
  return !!group;
}
module.exports = {
  findOrCreateOneToOneGroup,
  createGroup,
  saveMessage,
  getMessagesByGroup,
  isParticipant,
};
