const { Server } = require('socket.io');
const socketAuthMiddleware = require('../auth/socket.middleware');
const { registerChatHandlers } = require('../chat/chat.socket');

function setupSocket(server) {
  const io = new Server(server, {
    cors: { origin: '*' },
  });

  io.use(socketAuthMiddleware); // ✅ centralizes auth logic

  io.on('connection', (socket) => {
    console.log('✅ Socket connected:', socket.id, 'User:', socket.user?.email);
    registerChatHandlers(io, socket);
  });
}

module.exports = { setupSocket };
