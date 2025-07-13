const multer = require('multer');
const path = require('path');
const fs = require('fs');

const AVATAR_UPLOAD_DIR = path.join('uploads', 'avatars');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Ensure the directory exists
    fs.mkdirSync(AVATAR_UPLOAD_DIR, { recursive: true });
    cb(null, AVATAR_UPLOAD_DIR);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1e9) + ext;
    cb(null, uniqueName);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();
    if (!allowed.includes(ext)) {
      return cb(new Error('Only images are allowed'));
    }
    cb(null, true);
  },
});

module.exports = upload;
