const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const User = require('../models/User');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'secret123', {
        expiresIn: '30d',
    });
};

// @desc    Register new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
    const { name, email, password, phone } = req.body; // Added phone

    try {
        const userExists = await User.findByEmail(email);

        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Hash password here since no more pre-save hook
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = await User.create({
            name,
            email,
            password: hashedPassword,
            phone,
            role: 'user'
        });

        if (newUser) {
            res.status(201).json({
                _id: newUser._id, // User model create returns { _id, ... }
                name: newUser.name,
                email: newUser.email,
                phone: newUser.phone,
                role: newUser.role,
                image: newUser.image,
                token: generateToken(newUser._id),
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Authenticate a user
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findByEmail(email);

        if (user && (await bcrypt.compare(password, user.password))) {
            // Map id to _id for frontend compatibility
            res.json({
                _id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                role: user.role,
                image: user.image,
                token: generateToken(user.id),
            });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Forgot Password
// POST /api/auth/forgot-password
const forgotPassword = async (req, res) => {
    const { email } = req.body;
    try {
        const user = await User.findByEmail(email);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Save OTP to user (valid for 10 minutes)
        // Format date for MySQL DATETIME: 'YYYY-MM-DD HH:MM:SS'
        const expireTime = new Date(Date.now() + 10 * 60 * 1000);
        // Note: mysql2/prepared statements usually handle Date objects well, defaulting to correct format or UTC

        await User.saveOTP(user.id, otp, expireTime);

        // Send Email
        const transporter = nodemailer.createTransport({
            service: process.env.EMAIL_SERVICE || 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS,
            },
        });

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'HoySpace Password Reset Code',
            text: `Your password reset code is: ${otp} \n\nThis code will expire in 10 minutes.`,
        };

        try {
            await transporter.sendMail(mailOptions);
            res.json({ message: 'Verification code sent to email' });
        } catch (emailError) {
            console.error("Email send error:", emailError);
            res.status(200).json({ message: 'Email failed (Dev Mode: Check Console)', devOtp: otp });
        }

    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Verify OTP
// POST /api/auth/verify-otp
const verifyOTP = async (req, res) => {
    const { email, otp } = req.body;
    try {
        const user = await User.findByOTP(email, otp);

        if (!user) {
            return res.status(400).json({ message: 'Invalid or expired code' });
        }

        // OTP Valid
        res.json({ message: 'OTP Verified successfully', userId: user.id });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Reset Password
// POST /api/auth/reset-password
const resetPassword = async (req, res) => {
    const { email, otp, newPassword } = req.body;
    try {
        const user = await User.findByOTP(email, otp);

        if (!user) {
            return res.status(400).json({ message: 'Invalid or expired code' });
        }

        // Hash new password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        // Update password and clear OTP
        await User.update(user.id, {
            password: hashedPassword,
            resetPasswordOTP: null,
            resetPasswordExpire: null
        });

        res.json({ message: 'Password reset successful' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

module.exports = { registerUser, loginUser, forgotPassword, verifyOTP, resetPassword };
