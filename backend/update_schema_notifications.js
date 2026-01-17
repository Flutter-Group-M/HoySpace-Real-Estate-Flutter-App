const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const updateSchema = async () => {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME,
        });

        console.log('Connected to database.');

        const createNotificationsTable = `
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                type VARCHAR(50) DEFAULT 'system',
                is_read BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `;

        console.log('Creating notifications table...');
        await connection.query(createNotificationsTable);
        console.log('SUCCESS: Notifications table created.');

        await connection.end();
    } catch (error) {
        console.error('Schema Update Failed:', error);
        process.exit(1);
    }
};

updateSchema();
