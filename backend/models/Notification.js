const db = require('../config/db');

const Notification = {
    create: async (userId, title, message, type = 'system') => {
        const query = `
            INSERT INTO notifications (user_id, title, message, type)
            VALUES (?, ?, ?, ?)
        `;
        const [result] = await db.query(query, [userId, title, message, type]);
        return { id: result.insertId, user_id: userId, title, message, type, is_read: false };
    },

    getByUserId: async (userId) => {
        const query = `
            SELECT * FROM notifications 
            WHERE user_id = ? 
            ORDER BY created_at DESC
        `;
        const [rows] = await db.query(query, [userId]);
        return rows.map(row => ({
            ...row,
            is_read: row.is_read === 1 // Convert MySQL TINYINT to boolean
        }));
    },

    markRead: async (id) => {
        const query = 'UPDATE notifications SET is_read = TRUE WHERE id = ?';
        const [result] = await db.query(query, [id]);
        return result.affectedRows;
    },

    markAllRead: async (userId) => {
        const query = 'UPDATE notifications SET is_read = TRUE WHERE user_id = ?';
        const [result] = await db.query(query, [userId]);
        return result.affectedRows;
    }
};

module.exports = Notification;
