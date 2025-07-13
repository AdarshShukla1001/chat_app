const mongoose = require("mongoose");

const groupSchema = new mongoose.Schema(
  {
    isGroup: { type: Boolean, default: false },
    name: { type: String },
    image: { type: String, default: null }, // ✅ Group image URL
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    lastMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
      default: null,
    },
    description: { type: String, default: "" }, // ✅ Optional group description
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: function () {
        return this.isGroup;
      },
    },
    admins: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    isArchived: { type: Boolean, default: false }, // ✅ Soft delete/archive support
  },
  { timestamps: true }
);

groupSchema.index({ participants: 1 });

module.exports = mongoose.model("Group", groupSchema);
