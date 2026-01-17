const db = require('./config/db');

async function updateSchema() {
    try {
        const connection = await db.getConnection();
        console.log('Connected to database.');

        // Create messages table
        // id, sender_id, receiver_id, content, is_read, created_at
        const createMessagesTableQuery = `
            CREATE TABLE IF NOT EXISTS messages (
                id INT AUTO_INCREMENT PRIMARY KEY,
                sender_id INT NOT NULL,
                receiver_id INT NOT NULL,
                content TEXT NOT NULL,
                is_read BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `;

        await connection.query(createMessagesTableQuery);
        console.log('Messages table created or already exists.');

        connection.release();
        console.log('Schema update completed successfully.');
        process.exit();
    } catch (error) {
        console.error('Error updating schema:', error);
        process.exit(1);
    }
}

updateSchema();
