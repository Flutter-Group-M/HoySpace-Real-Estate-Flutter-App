const Space = require('../models/Space');

// @desc    Fetch all spaces
// @route   GET /api/spaces
// @access  Public
const getSpaces = async (req, res) => {
    try {
        const { search, location, category } = req.query;
        const spaces = await Space.getAll({ search, location, category });
        res.json(spaces);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Fetch single space
// @route   GET /api/spaces/:id
// @access  Public
const getSpaceById = async (req, res) => {
    try {
        const space = await Space.findById(req.params.id);

        if (space) {
            res.json(space);
        } else {
            res.status(404).json({ message: 'Space not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a space
// @route   POST /api/spaces
// @access  Private/Admin
const createSpace = async (req, res) => {
    try {
        const { title, description, price, location, images, amenities, category } = req.body;

        const spaceData = {
            title,
            description,
            price,
            location,
            images,
            amenities,
            category,
            host_id: req.user.id, // Ensure auth middleware adds user to req (and is using new User model/interface)
        };

        const createdSpace = await Space.create(spaceData);
        res.status(201).json(createdSpace);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update a space
// @route   PUT /api/spaces/:id
// @access  Private/Admin
const updateSpace = async (req, res) => {
    try {
        const { title, description, price, location, images, amenities, category } = req.body;

        // Check if space exists? Or just update.
        // For simplicity, just update. If 0 rows affected, it likely doesn't exist or no change.
        const updatedRows = await Space.update(req.params.id, {
            title,
            description,
            price,
            location,
            images,
            amenities,
            category
        });

        if (updatedRows > 0) {
            const updatedSpace = await Space.findById(req.params.id);
            res.json(updatedSpace);
        } else {
            // Could specifically check if id exists if we wanted to be more precise between 404 and "no change"
            const space = await Space.findById(req.params.id);
            if (space) {
                res.json(space); // No changes but exists
            } else {
                res.status(404).json({ message: 'Space not found' });
            }
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Delete a space
// @route   DELETE /api/spaces/:id
// @access  Private/Admin
const deleteSpace = async (req, res) => {
    try {
        const deletedRows = await Space.delete(req.params.id);

        if (deletedRows > 0) {
            res.json({ message: 'Space removed' });
        } else {
            res.status(404).json({ message: 'Space not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getSpaces,
    getSpaceById,
    createSpace,
    updateSpace,
    deleteSpace,
};
