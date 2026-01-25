const Booking = require('../models/Booking');
const Notification = require('../models/Notification');

// @desc    Create new booking
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res) => {
    const { spaceId, checkIn, checkOut, totalPrice } = req.body;

    try {
        if (!spaceId || !checkIn || !checkOut || !totalPrice) {
            return res.status(400).json({ message: 'Please provide all booking details' });
        }

        // Restrict Admins from booking
        if (req.user.role === 'admin') {
            return res.status(403).json({ message: 'Admins cannot book spaces.' });
        }

        const bookingData = {
            user_id: req.user.id,
            space_id: spaceId,
            checkIn,
            checkOut,
            totalPrice,
            status: 'pending'
        };

        const createdBooking = await Booking.create(bookingData);

        // SYSTEM NOTIFICATION: Booking Created
        await Notification.create(
            req.user.id,
            'Booking Request Sent',
            `Your booking request for space ID #${spaceId} has been sent.`,
            'booking'
        );

        res.status(201).json(createdBooking);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get logged in user bookings
// @route   GET /api/bookings/mybookings
// @access  Private
const getMyBookings = async (req, res) => {
    try {
        const bookings = await Booking.findByUserId(req.user.id);
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all bookings
// @route   GET /api/bookings
// @access  Private/Admin
const getBookings = async (req, res) => {
    try {
        const bookings = await Booking.getAll();
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update booking status
// @route   PUT /api/bookings/:id
// @access  Private/Admin
const updateBooking = async (req, res) => {
    try {
        const { status } = req.body;

        const updatedRows = await Booking.update(req.params.id, { status });

        if (updatedRows > 0) {
            const updatedBooking = await Booking.findById(req.params.id);

            // SYSTEM NOTIFICATION: Status Update
            if (updatedBooking) {
                await Notification.create(
                    updatedBooking.user_id,
                    `Booking ${status.charAt(0).toUpperCase() + status.slice(1)}`,
                    `Your booking for ${updatedBooking.space ? updatedBooking.space.title : 'a space'} has been ${status}.`,
                    'booking'
                );
            }

            res.json(updatedBooking);
        } else {
            res.status(404).json({ message: 'Booking not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Delete booking
// @route   DELETE /api/bookings/:id
// @access  Private/Admin (Or User if own booking)
const deleteBooking = async (req, res) => {
    try {
        const booking = await Booking.findById(req.params.id);

        if (booking) {
            // Allow admin or the user who owns the booking to delete/cancel
            if (req.user.role === 'admin' || booking.user_id == req.user.id) {
                await Booking.delete(req.params.id);
                res.json({ message: 'Booking removed' });
            } else {
                res.status(401).json({ message: 'Not authorized to delete this booking' });
            }
        } else {
            res.status(404).json({ message: 'Booking not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createBooking,
    getMyBookings,
    getBookings,
    updateBooking,
    deleteBooking,
};
