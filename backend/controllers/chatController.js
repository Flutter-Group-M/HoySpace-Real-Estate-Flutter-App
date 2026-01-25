const db = require('../config/db');

// @desc    Send a message
// @route   POST /api/chat
// @access  Private
const sendMessage = async (req, res) => {
    const { receiverId, content } = req.body;

    if (!receiverId || !content) {
        return res.status(400).json({ message: 'Receiver and content are required' });
    }

    try {
        const senderId = req.user.id;

        // Insert message
        const [result] = await db.query(
            'INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)',
            [senderId, receiverId, content]
        );

        const newMsgId = result.insertId;

        // Fetch the inserted message with sender/receiver details
        const query = `
            SELECT m.*, 
                   s.id as sender_id, s.name as sender_name, s.image as sender_image,
                   r.id as receiver_id, r.name as receiver_name, r.image as receiver_image
            FROM messages m
            JOIN users s ON m.sender_id = s.id
            JOIN users r ON m.receiver_id = r.id
            WHERE m.id = ?
        `;

        const [rows] = await db.query(query, [newMsgId]);
        const message = rows[0];

        // Format to match expected frontend structure (simulating population)
        const formattedMessage = {
            _id: message.id, // Frontend expects underscore ID from Mongo days? Or we update frontend.
            id: message.id,
            content: message.content,
            sender: { _id: message.sender_id, id: message.sender_id, name: message.sender_name, image: message.sender_image },
            receiver: { _id: message.receiver_id, id: message.receiver_id, name: message.receiver_name, image: message.receiver_image },
            createdAt: message.created_at
        };

        res.json(formattedMessage);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get messages between current user and another user
// @route   GET /api/chat/:userId
// @access  Private
const getMessages = async (req, res) => {
    try {
        const currentUserId = req.user.id;
        const otherUserId = req.params.userId;

        const query = `
            SELECT m.*, 
                   s.id as sender_id, s.name as sender_name, s.image as sender_image,
                   r.id as receiver_id, r.name as receiver_name, r.image as receiver_image
            FROM messages m
            JOIN users s ON m.sender_id = s.id
            JOIN users r ON m.receiver_id = r.id
            WHERE (m.sender_id = ? AND m.receiver_id = ?) 
               OR (m.sender_id = ? AND m.receiver_id = ?)
            ORDER BY m.created_at ASC
        `;

        const [messages] = await db.query(query, [currentUserId, otherUserId, otherUserId, currentUserId]);

        const formattedMessages = messages.map(msg => ({
            _id: msg.id,
            id: msg.id,
            content: msg.content,
            sender: { _id: msg.sender_id, id: msg.sender_id, name: msg.sender_name, image: msg.sender_image },
            receiver: { _id: msg.receiver_id, id: msg.receiver_id, name: msg.receiver_name, image: msg.receiver_image },
            createdAt: msg.created_at
        }));

        res.json(formattedMessages);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all conversations (unique users chatted with)
// @route   GET /api/chat/conversations
// @access  Private
const getConversations = async (req, res) => {
    try {
        const userId = req.user.id;

        // Complex query to get latest message per conversation partner
        // We want the partner's info and the last message content/time
        const query = `
            SELECT 
                u.id as partner_id, u.name as partner_name, u.image as partner_image, u.email as partner_email,
                m.content as last_message, m.created_at as time,
                (SELECT COUNT(*) FROM messages 
                 WHERE receiver_id = ? AND sender_id = u.id AND is_read = FALSE) as unread_count
            FROM users u
            JOIN (
                SELECT 
                    CASE 
                        WHEN sender_id = ? THEN receiver_id 
                        ELSE sender_id 
                    END as partner_id,
                    MAX(id) as max_msg_id
                FROM messages
                WHERE sender_id = ? OR receiver_id = ?
                GROUP BY partner_id
            ) latest ON u.id = latest.partner_id
            JOIN messages m ON m.id = latest.max_msg_id
            ORDER BY m.created_at DESC
        `;

        const [rows] = await db.query(query, [userId, userId, userId, userId]);

        const conversations = rows.map(row => ({
            user: { _id: row.partner_id, id: row.partner_id, name: row.partner_name, image: row.partner_image, email: row.partner_email },
            lastMessage: row.last_message,
            time: row.time,
            unreadCount: row.unread_count
        }));

        res.json(conversations);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { sendMessage, getMessages, getConversations };
