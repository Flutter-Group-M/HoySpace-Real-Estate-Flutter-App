const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const createAdmin = async () => {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            port: process.env.DB_PORT || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'hoyspace'
        });

        console.log('Connected to MySQL...');

        const email = 'admin@hoyspace.com';
        const password = 'admin123';
        const name = 'Admin User';
        const role = 'admin';

        // Check if user exists
        const [existingUsers] = await connection.query('SELECT * FROM users WHERE email = ?', [email]);

        if (existingUsers.length > 0) {
            console.log('Admin user already exists!');
            process.exit(0);
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert Admin
        // Image default: https://images.unsplash.com/photo-1535713875002-d1d0cf377fde
        const [result] = await connection.query(
            'INSERT INTO users (name, email, password, role, image) VALUES (?, ?, ?, ?, ?)',
            [name, email, hashedPassword, role, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde']
        );

        console.log(`Admin user created successfully!`);
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);

        await connection.end();
        process.exit();

    } catch (error) {
        console.error('Error creating admin:', error);

        // Check if DB doesn't exist
        if (error.code === 'ER_BAD_DB_ERROR') {
            console.error('Database does not exist. Please run "node init_db.js" first.');
        }

        process.exit(1);
    }
};

createAdmin();
