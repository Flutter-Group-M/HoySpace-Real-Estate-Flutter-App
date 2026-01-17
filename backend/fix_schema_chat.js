const db = require('./config/db');

async function fixSchema() {
    try {
        const connection = await db.getConnection();
        console.log('Connected.');

        try {
            await connection.query("ALTER TABLE messages ADD COLUMN is_read BOOLEAN DEFAULT FALSE");
            console.log("Added is_read column.");
        } catch (e) {
            console.log("Column likely exists or error:", e.message);
        }

        connection.release();
        process.exit();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

fixSchema();
