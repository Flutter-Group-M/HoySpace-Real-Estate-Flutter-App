const express = require('express');
const router = express.Router();
const { sendMessage, getMessages, getConversations } = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');

router.route('/').post(protect, sendMessage);
router.route('/conversations').get(protect, getConversations);
router.route('/:userId').get(protect, getMessages);

module.exports = router;
