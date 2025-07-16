const CallLog = require('./call.model');

exports.getCallLogs = async (req, res) => {
  try {
    const userId = req.user._id;

    const calls = await CallLog.find({
      $or: [{ caller: userId }, { callee: userId }]
    }).sort({ createdAt: -1 });

    res.json(calls);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
