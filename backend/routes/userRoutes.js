const express = require('express');
const router = express.Router();
const { getUsers, updateUserProfile, deleteUser, getUserStats, createUser, updateUserById } = require('../controllers/userController');
const { protect, admin } = require('../middleware/authMiddleware');

router.route('/').get(protect, admin, getUsers).post(protect, admin, createUser);
router.route('/stats').get(protect, getUserStats);
router.route('/profile').put(protect, updateUserProfile);
router.route('/:id').delete(protect, admin, deleteUser).put(protect, admin, updateUserById);

module.exports = router;
