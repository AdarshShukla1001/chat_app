const mongoose = require('mongoose');

const callSchema = new mongoose.Schema({
  caller: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  callee: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  startedAt: { type: Date, default: Date.now },
  endedAt: { type: Date },
  status: {
    type: String,
    enum: ['missed', 'ended', 'rejected'],
    default: 'missed'
  },
  isVideo: { type: Boolean, default: false },
  duration: { type: Number }, // in seconds
}, { timestamps: true });

module.exports = mongoose.model('CallLog', callSchema);
