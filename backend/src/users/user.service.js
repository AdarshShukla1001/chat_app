const path = require("path");
const User = require("./user.model");
const Upload = require("../common/utils/upload");

async function getCurrentUser(user) {
  return user; // already fetched in middleware
}

async function updateCurrentUser(user, updates) {
  Object.assign(user, updates);
  return await user.save();
}

async function updateCurrentUser(user, updates) {
  Object.assign(user, updates);
  return await user.save();
}

async function updateAvatar(userId, file) {
  if (!file) {
    throw new Error("No file uploaded");
  }

  const filePath = path.join("uploads/avatars", file.filename);

  console.log(`🗃️ Saving avatar to userId ${userId}: ${filePath}`);

  const updatedUser = await User.findByIdAndUpdate(
    userId,
    { avatar: filePath },
    { new: true }
  );

  if (!updatedUser) {
    console.error(`❌ User not found with ID: ${userId}`);
    throw new Error("User not found");
  }

  console.log(`✅ User updated successfully: ${updatedUser._id}`);
  return updatedUser;
}


function handleAvatarUpload(req, res, userId) {
  return new Promise((resolve, reject) => {
    const uploadSingle = Upload.single("avatar");

    uploadSingle(req, res, async (err) => {
      if (err) {
        console.error("❌ Multer error:", err.message);
        return reject(err);
      }

      if (!req.file) {
        console.warn("⚠️ No file was uploaded.");
        return reject(new Error("No file uploaded"));
      }

      console.log("📦 File received:", req.file.originalname);

      try {
        const updatedUser = await updateAvatar(userId, req.file);
        resolve(updatedUser);
      } catch (error) {
        console.error("❌ Error updating avatar in DB:", error.message);
        reject(error);
      }
    });
  });
}

module.exports = {
  getCurrentUser,
  updateCurrentUser,
  handleAvatarUpload,
};
