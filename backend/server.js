const http = require("http");
const app = require("./src/app");
const { setupSocket } = require("./src/config/socket");
const logger = require("./src/common/utils/logger");

const connectDB = require("./src/config/db");
connectDB();

const server = http.createServer(app);
setupSocket(server); // initialize Socket.IO

const PORT = process.env.PORT || 5001;
server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
