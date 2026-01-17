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

        // Update users table image column
        console.log('Modifying users table...');
        await connection.query('ALTER TABLE users MODIFY COLUMN image LONGTEXT');
        console.log('SUCCESS: Changed users.image to LONGTEXT.');

        // Check spaces table images column (JSON is good, but ensuring it exists)
        // No change needed for JSON type as it handles large data well enough for arrays of URLs/Base64.

        console.log('Schema update complete.');
        await connection.end();
    } catch (error) {
        console.error('Schema Update Failed:', error);
        process.exit(1);
    }
};

updateSchema();
