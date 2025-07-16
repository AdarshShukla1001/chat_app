const CallLog = require('./call.model');

const activeCalls = new Map(); // Temporary in-memory tracking

socket.on('call:offer', async ({ toUserId, offer, isVideo = false }) => {
  const fromUserId = socket.user._id.toString();

  const call = await CallLog.create({
    caller: fromUserId,
    callee: toUserId,
    isVideo,
    status: 'missed', // Update later
  });

  activeCalls.set(`${fromUserId}_${toUserId}`, call._id);

  io.to(toUserId).emit('call:offer', { fromUserId, offer });
});

socket.on('call:answer', async ({ toUserId, answer }) => {
  const fromUserId = socket.user._id.toString();

  const callId = activeCalls.get(`${toUserId}_${fromUserId}`);
  if (callId) {
    await CallLog.findByIdAndUpdate(callId, {
      status: 'ended',
      startedAt: new Date(),
    });
  }

  io.to(toUserId).emit('call:answer', { fromUserId, answer });
});

socket.on('call:end', async ({ toUserId }) => {
  const fromUserId = socket.user._id.toString();
  const callId = activeCalls.get(`${fromUserId}_${toUserId}`) || activeCalls.get(`${toUserId}_${fromUserId}`);

  if (callId) {
    const call = await CallLog.findById(callId);
    if (call) {
      call.endedAt = new Date();
      call.status = 'ended';
      call.duration = Math.floor((call.endedAt - call.startedAt) / 1000);
      await call.save();
    }
    activeCalls.delete(`${fromUserId}_${toUserId}`);
    activeCalls.delete(`${toUserId}_${fromUserId}`);
  }

  io.to(toUserId).emit('call:end', { fromUserId });
});
