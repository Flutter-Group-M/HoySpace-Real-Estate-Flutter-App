const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const init = async () => {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            port: process.env.DB_PORT || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            multipleStatements: true // Enable multiple statements for schema execution
        });

        console.log('Connected to MySQL...');

        // Create Database if not exists
        const dbName = process.env.DB_NAME || 'hoyspace';
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${dbName}`);
        console.log(`Database ${dbName} created or already exists.`);

        await connection.query(`USE ${dbName}`);

        // Read schema.sql
        const schemaPath = path.join(__dirname, 'schema.sql');
        const schema = fs.readFileSync(schemaPath, 'utf8');

        // Execute schema
        await connection.query(schema);
        console.log('Tables created successfully.');

        await connection.end();
        process.exit();
    } catch (error) {
        console.error('Error initializing database:', error);
        process.exit(1);
    }
};

init();
