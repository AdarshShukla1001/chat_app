const jwt = require('jsonwebtoken');
const User = require('../users/user.model');

async function socketAuthMiddleware(socket, next) {
  try {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('Auth token missing'));

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);

    if (!user) return next(new Error('User not found'));

    socket.user = user;
    next();
  } catch (err) {
    console.error('❌ Socket Auth Error:', err.message);
    return next(new Error('Authentication failed'));
  }
}

module.exports = socketAuthMiddleware;
