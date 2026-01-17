const db = require('../config/db');

const Booking = {
    create: async (booking) => {
        const { user_id, space_id, checkIn, checkOut, totalPrice, status } = booking;
        const [result] = await db.query(
            'INSERT INTO bookings (user_id, space_id, checkIn, checkOut, totalPrice, status) VALUES (?, ?, ?, ?, ?, ?)',
            [user_id, space_id, checkIn, checkOut, totalPrice, status || 'pending']
        );
        return { id: result.insertId, ...booking };
    },

    findByUserId: async (userId) => {
        const query = `
            SELECT b.*, 
            s.title as space_title, s.images as space_images, s.location as space_location
            FROM bookings b
            JOIN spaces s ON b.space_id = s.id
            WHERE b.user_id = ?
            ORDER BY b.created_at DESC
        `;
        const [rows] = await db.query(query, [userId]);
        return rows.map(row => ({
            ...row,
            space: {
                title: row.space_title,
                images: typeof row.space_images === 'string' ? JSON.parse(row.space_images) : row.space_images,
                location: row.space_location
            }
        }));
    },

    getAll: async () => {
        const query = `
            SELECT b.*, 
            s.title as space_title, s.location as space_location,
            u.name as user_name, u.email as user_email
            FROM bookings b
            JOIN spaces s ON b.space_id = s.id
            JOIN users u ON b.user_id = u.id
            ORDER BY b.created_at DESC
        `;
        const [rows] = await db.query(query);
        return rows.map(row => ({
            ...row,
            // Aliasing for frontend compatibility
            id: row.id,
            space: {
                _id: row.space_id,
                title: row.space_title,
                location: row.space_location
            },
            user: {
                _id: row.user_id,
                name: row.user_name,
                email: row.user_email
            }
        }));
    },

    findById: async (id) => {
        const query = `
            SELECT b.*, 
            s.title as space_title, s.location as space_location,
            u.name as user_name, u.email as user_email
            FROM bookings b
            JOIN spaces s ON b.space_id = s.id
            JOIN users u ON b.user_id = u.id
            WHERE b.id = ?
        `;
        const [rows] = await db.query(query, [id]);
        if (rows.length === 0) return null;

        const row = rows[0];
        return {
            ...row,
            space: {
                _id: row.space_id,
                title: row.space_title,
                location: row.space_location
            },
            user: {
                _id: row.user_id,
                name: row.user_name,
                email: row.user_email
            }
        };
    },

    update: async (id, bookingData) => {
        const fields = [];
        const values = [];

        if (bookingData.status) {
            fields.push('status = ?');
            values.push(bookingData.status);
        }

        if (fields.length === 0) return 0;

        values.push(id);
        const [result] = await db.query(
            `UPDATE bookings SET ${fields.join(', ')} WHERE id = ?`,
            values
        );
        return result.affectedRows;
    },

    delete: async (id) => {
        const [result] = await db.query('DELETE FROM bookings WHERE id = ?', [id]);
        return result.affectedRows;
    }
};

module.exports = Booking;
