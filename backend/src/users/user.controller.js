const userService = require("./user.service");

exports.getMe = async (req, res) => {
  try {
    const user = req.user; // already fetched in auth middleware
    const baseUrl = `${req.protocol}://${req.get("host")}`;

    const formattedUser = {
      ...user.toObject(), // ensure it's a plain object
      avatar: user.avatar
        ? `${baseUrl}/${user.avatar.replace(/\\/g, "/")}`
        : null,
    };

    res.json(formattedUser);
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

exports.uploadAvatar = async (req, res) => {
  try {
    const userId = req.user.id;
    console.log(`📥 Received avatar upload request for userId: ${userId}`);

    const updatedUser = await userService.handleAvatarUpload(req, res, userId);

    console.log(`✅ Avatar uploaded successfully for userId: ${userId}`);
    console.log(`🖼️ Saved avatar path: ${updatedUser.avatar}`);

    res.json({
      message: "Avatar uploaded successfully",
      avatar: updatedUser.avatar,
    });
  } catch (error) {
    console.error(`❌ Avatar upload failed: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
};
