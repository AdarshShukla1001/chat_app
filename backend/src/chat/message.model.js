const mongoose = require("mongoose");
const messageSchema = new mongoose.Schema(
  {
    group: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Group",
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: {
      type: String,
      required: true,
    },

    // 👁 Seen status per user
    seenBy: {
      type: Map,
      of: Boolean, // userId -> true/false
      default: {},
    },

    // ❤️ Reactions per user
    reactions: {
      type: Map,
      of: [String], // userId -> ['❤️', '😂']
      default: {},
    },

    // 🔗 Threaded replies
    parentMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
      default: null,
    },

    // 📎 Attachments (optional)
    attachments: [
      {
        type: {
          type: String, // image, video, file, etc.
          enum: ["image", "video", "file", "audio"],
        },
        url: String,
        fileName: String,
        mimeType: String,
      },
    ],

    deleted: {
      type: Boolean,
      default: false,
    },

    edited: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Message", messageSchema);
