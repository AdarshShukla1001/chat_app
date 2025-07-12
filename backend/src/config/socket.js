const jwt = require('jsonwebtoken');
const User = require('../users/user.model');
const { registerChatHandlers } = require('../chat/chat.socket');

function setupSocket(server) {
  const io = require('socket.io')(server, {
    cors: { origin: '*' },
  });

  // ✅ Add auth middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) return next(new Error('Auth token missing'));

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId);

      if (!user) return next(new Error('User not found'));

      socket.user = user; // ✅ Attach user to socket
      next();
    } catch (err) {
      console.error('Socket auth error:', err.message);
      next(new Error('Authentication failed'));
    }
  });

  io.on('connection', (socket) => {
    console.log('✅ Socket connected:', socket.id, 'User:', socket.user?.email);
    registerChatHandlers(io, socket);
  });
}

module.exports = { setupSocket };
