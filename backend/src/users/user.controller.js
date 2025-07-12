const userService = require('./user.service');

exports.getMe = async (req, res) => {
  try {
    const user = await userService.getCurrentUser(req.user);
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateMe = async (req, res) => {
  try {
    const user = await userService.updateCurrentUser(req.user, req.body);
    res.json(user);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};
