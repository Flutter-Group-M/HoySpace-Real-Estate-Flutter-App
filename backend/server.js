const express = require('express');
<<<<<<< Updated upstream
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
const morgan = require('morgan');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');

dotenv.config();
=======
const dotenv = require('dotenv');

dotenv.config();

const cors = require('cors');
const morgan = require('morgan');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');
const db = require('./config/db'); // MySQL pool
>>>>>>> Stashed changes

const app = express();

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
<<<<<<< Updated upstream
app.use(cors());
app.use(morgan('dev'));

// Database Connection
const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/hoyspace');
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};
=======
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(morgan('dev'));

// Test Database Connection
db.getConnection()
    .then(connection => {
        console.log('MySQL Connected');
        connection.release();
    })
    .catch(err => {
        console.error('MySQL Connection Error:', err);
    });

>>>>>>> Stashed changes

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const spaceRoutes = require('./routes/spaceRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
<<<<<<< Updated upstream
=======
const chatRoutes = require('./routes/chatRoutes'); // Comment out if chat not ready for mysql conversion
>>>>>>> Stashed changes

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/spaces', spaceRoutes);
app.use('/api/bookings', bookingRoutes);
<<<<<<< Updated upstream
app.use('/api/chat', require('./routes/chatRoutes'));
=======
const notificationRoutes = require('./routes/notificationRoutes');
app.use('/api/notifications', notificationRoutes);
app.use('/api/chat', chatRoutes);
>>>>>>> Stashed changes

app.get('/', (req, res) => {
    res.send('HoySpace API is running...');
});

// Error Middleware
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

<<<<<<< Updated upstream
connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
=======
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
>>>>>>> Stashed changes
});
