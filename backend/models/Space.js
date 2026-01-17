const db = require('../config/db');

const Space = {
    getAll: async (filters = {}) => {
        // Join with host (users) to get host details
        const query = `
            SELECT s.*,
            u.name as host_name, u.email as host_email, u.image as host_image 
            FROM spaces s 
            LEFT JOIN users u ON s.host_id = u.id
        WHERE(1 = 1) 
            ${filters.search ? `AND (s.title LIKE ? OR s.description LIKE ? OR s.location LIKE ?)` : ''}
            ${filters.location ? `AND s.location LIKE ?` : ''}
            ${filters.category ? `AND s.category = ?` : ''}
        `;

        const queryParams = [];
        if (filters.search) {
            queryParams.push(`%${filters.search}%`, `%${filters.search}%`, `%${filters.search}%`);
        }
        if (filters.location) {
            queryParams.push(`% ${filters.location}% `);
        }
        if (filters.category) {
            queryParams.push(filters.category);
        }

        const [rows] = await db.query(query, queryParams);
        return rows.map(row => ({
            ...row,
            // Parse JSON fields back to arrays
            _id: row.id, // Map for frontend compatibility
            images: typeof row.images === 'string' ? JSON.parse(row.images) : row.images,
            amenities: typeof row.amenities === 'string' ? JSON.parse(row.amenities) : row.amenities,
            host: {
                _id: row.host_id,
                name: row.host_name,
                email: row.host_email,
                image: row.host_image
            }
        }));
    }, // Note: Keeping structure similar to populated mongoose result for frontend compatibility

    findById: async (id) => {
        const query = `
            SELECT s.*,
            u.name as host_name, u.email as host_email, u.image as host_image 
            FROM spaces s 
            LEFT JOIN users u ON s.host_id = u.id
            WHERE s.id = ?
            `;
        const [rows] = await db.query(query, [id]);
        if (rows.length === 0) return null;

        const row = rows[0];
        return {
            ...row,
            _id: row.id,
            images: typeof row.images === 'string' ? JSON.parse(row.images) : row.images,
            amenities: typeof row.amenities === 'string' ? JSON.parse(row.amenities) : row.amenities,
            host: {
                _id: row.host_id, // Map host_id to _id for frontend compatibility? Or update frontend.
                // Keeping _id might be safer for minimal frontend breakage if it expects _id
                id: row.host_id,
                name: row.host_name,
                email: row.host_email,
                image: row.host_image
            }
        };
    },

    create: async (space) => {
        const { title, description, price, location, images, amenities, host_id, category } = space;

        const [result] = await db.query(
            'INSERT INTO spaces (title, description, price, location, images, amenities, host_id, category) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [
                title,
                description,
                price,
                location,
                JSON.stringify(images || []),
                JSON.stringify(amenities || []),
                host_id,
                category || 'Other'
            ]
        );
        return { id: result.insertId, _id: result.insertId, ...space };
    },

    update: async (id, spaceData) => {
        const fields = [];
        const values = [];

        const simpleFields = ['title', 'description', 'price', 'location', 'category'];
        simpleFields.forEach(field => {
            if (spaceData[field] !== undefined) {
                fields.push(`${field} = ?`);
                values.push(spaceData[field]);
            }
        });

        if (spaceData.images) {
            fields.push('images = ?');
            values.push(JSON.stringify(spaceData.images));
        }
        if (spaceData.amenities) {
            fields.push('amenities = ?');
            values.push(JSON.stringify(spaceData.amenities));
        }

        if (fields.length === 0) return 0;

        values.push(id);
        const [result] = await db.query(
            `UPDATE spaces SET ${fields.join(', ')} WHERE id = ? `,
            values
        );
        return result.affectedRows;
    },

    delete: async (id) => {
        const [result] = await db.query('DELETE FROM spaces WHERE id = ?', [id]);
        return result.affectedRows;
    }
};

module.exports = Space;
