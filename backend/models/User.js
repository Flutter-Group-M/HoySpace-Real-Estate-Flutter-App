const db = require('../config/db');

const User = {
    create: async (user) => {
        const { name, email, password, phone, role, image } = user;
        const [result] = await db.query(
            'INSERT INTO users (name, email, password, phone, role, image) VALUES (?, ?, ?, ?, ?, ?)',
            [name, email, password, phone, role || 'user', image || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde']
        );
        return { _id: result.insertId, ...user };
    },

    findByEmail: async (email) => {
        const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        return rows[0];
    },

    findById: async (id) => {
        const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [id]);
        return rows[0];
    },

    update: async (id, userData) => {
        // Dynamic update query
        const fields = [];
        const values = [];
        for (const [key, value] of Object.entries(userData)) {
            if (value !== undefined) {
                fields.push(`${key} = ?`);
                values.push(value);
            }
        }
        if (fields.length === 0) return 0;

        values.push(id);
        const [result] = await db.query(
            `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
            values
        );
        return result.affectedRows;
    },

    // For password reset token
    saveOTP: async (id, otp, expire) => {
        const [result] = await db.query(
            'UPDATE users SET resetPasswordOTP = ?, resetPasswordExpire = ? WHERE id = ?',
            [otp, expire, id]
        );
        return result.affectedRows;
    },

    findByOTP: async (email, otp) => {
        // Check OTP and Expiry
        const [rows] = await db.query(
            'SELECT * FROM users WHERE email = ? AND resetPasswordOTP = ? AND resetPasswordExpire > NOW()',
            [email, otp]
        );
        return rows[0];
    },

    getAll: async () => {
        const [rows] = await db.query('SELECT *, id as _id FROM users');
        return rows;
    },

    delete: async (id) => {
        const [result] = await db.query('DELETE FROM users WHERE id = ?', [id]);
        return result.affectedRows;
    }
};

module.exports = User;
