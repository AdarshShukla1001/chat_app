const express = require("express");
const cors = require("cors");
require("dotenv").config();
const morgan = require("morgan");

const logger = require("./common/utils/logger");

const authRoutes = require("./auth/auth.routes");
const userRoutes = require("./users/user.routes");
const chatRoutes = require("./chat/chat.routes");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Log each request to terminal using morgan + winston
app.use(
  morgan(
    (tokens, req, res) => {
      return [
        tokens.method(req, res),
        tokens.url(req, res),
        tokens.status(req, res),
        "-",
        tokens["response-time"](req, res),
        "ms",
      ].join(" ");
    },
    {
      stream: {
        write: (message) => logger.info(message.trim()),
      },
    }
  )
);
app.use("/api/chat", chatRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

app.use("/uploads", express.static("uploads"));

module.exports = app;
