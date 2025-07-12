const express = require('express');
const router = express.Router();
const chatController = require('./chat.controller');
const { protect } = require('../auth/auth.middleware');

router.get('/one-to-one/:userId', protect, chatController.getOneToOneMessages);
router.get('/group/:groupId', protect, chatController.getGroupMessages);
router.post('/group', protect, chatController.createGroup);

module.exports = router;
