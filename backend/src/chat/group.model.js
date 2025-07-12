const mongoose = require('mongoose');

const groupSchema = new mongoose.Schema(
  {
    isGroup: { type: Boolean, default: false },
    name: { type: String },
    participants: [
      { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
    ]
  },
  { timestamps: true }
);

groupSchema.index({ participants: 1 });

module.exports = mongoose.model('Group', groupSchema);
