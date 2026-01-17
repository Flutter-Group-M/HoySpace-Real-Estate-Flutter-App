const db = require('./config/db');

async function debugChat() {
    try {
        console.log('Fetching a user ID...');
        const [users] = await db.query('SELECT id FROM users LIMIT 1');
        if (users.length === 0) {
            console.log('No users found in DB.');
            process.exit(0);
        }
        const userId = users[0].id;
        console.log('Testing with User ID:', userId);

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

        console.log('Running query...');
        const [rows] = await db.query(query, [userId, userId, userId, userId]);
        console.log('Query success! Rows:', rows.length);
        console.log(rows);

    } catch (error) {
        console.error('SQL Error:', error.message);
        console.error('Full Error:', error);
    } finally {
        process.exit();
    }
}

debugChat();
