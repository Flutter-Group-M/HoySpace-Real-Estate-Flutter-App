const User = require('../models/User');
const db = require('../config/db'); // For raw queries if needed
const bcrypt = require('bcryptjs');

// @desc    Get all users
// @route   GET /api/users
// @access  Private/Admin
const getUsers = async (req, res) => {
    try {
        const users = await User.getAll();
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);

        if (user) {
            const updateData = {};
            if (req.body.name) updateData.name = req.body.name;
            if (req.body.email) updateData.email = req.body.email;
            if (req.body.phone) updateData.phone = req.body.phone;
            if (req.body.image) updateData.image = req.body.image;

            if (req.body.password) {
                const salt = await bcrypt.genSalt(10);
                updateData.password = await bcrypt.hash(req.body.password, salt);
            }

            const updatedRows = await User.update(req.user.id, updateData);

            // Fetch updated user
            const updatedUser = await User.findById(req.user.id);

            res.json({
                _id: updatedUser.id,
                name: updatedUser.name,
                email: updatedUser.email,
                phone: updatedUser.phone,
                role: updatedUser.role,
                image: updatedUser.image,
                token: req.headers.authorization ? req.headers.authorization.split(' ')[1] : null,
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.error('Update Profile Error:', error);
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ message: 'Email already in use' });
        } else {
            res.status(500).json({ message: error.message });
        }
    }
};

// @desc    Delete user
// @route   DELETE /api/users/:id
// @access  Private/Admin
const deleteUser = async (req, res) => {
    try {
        const deletedRows = await User.delete(req.params.id);

        if (deletedRows > 0) {
            res.json({ message: 'User removed' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get user stats (bookings, reviews, saved)
// @route   GET /api/users/stats
// @access  Private
const getUserStats = async (req, res) => {
    try {
        // Bookings count
        const [bookingRows] = await db.query('SELECT COUNT(*) as count FROM bookings WHERE user_id = ?', [req.user.id]);
        const bookingsCount = bookingRows[0].count;

        // Saved count (Saved spaces are not yet in SQL schema, assuming 0 for now or need table)
        // Ignoring savedSpaces for now as per schema provided
        const savedCount = 0;
        const reviewsCount = 0;

        res.json({
            bookings: bookingsCount,
            reviews: reviewsCount,
            saved: savedCount
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create user (Admin)
// @route   POST /api/users
// @access  Private/Admin
const createUser = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        const userExists = await User.findByEmail(email);
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = await User.create({
            name,
            email,
            password: hashedPassword,
            role: role || 'user'
        });

        if (newUser) {
            res.status(201).json({
                _id: newUser._id,
                name: newUser.name,
                email: newUser.email,
                role: newUser.role,
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update user by ID (Admin)
// @route   PUT /api/users/:id
// @access  Private/Admin
const updateUserById = async (req, res) => {
    try {
        const updateData = {};
        if (req.body.name) updateData.name = req.body.name;
        if (req.body.email) updateData.email = req.body.email;
        if (req.body.role) updateData.role = req.body.role;

        const updatedRows = await User.update(req.params.id, updateData);

        if (updatedRows > 0) {
            const updatedUser = await User.findById(req.params.id);
            res.json({
                _id: updatedUser.id,
                name: updatedUser.name,
                email: updatedUser.email,
                role: updatedUser.role,
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ message: 'Email already in use' });
        } else {
            res.status(500).json({ message: error.message });
        }
    }
};

module.exports = { getUsers, updateUserProfile, deleteUser, getUserStats, createUser, updateUserById };
