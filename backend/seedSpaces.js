const db = require('./config/db');
const Space = require('./models/Space');
const User = require('./models/User'); // We might not need the model object if we query directly, but let's keep it clean
const dotenv = require('dotenv');

dotenv.config();

const spaces = [
    {
        title: "Modern Beachfront Villa",
        description: "Wake up to the sound of waves in this stunning beachfront villa. Features infinity pool, private beach access, and chef's kitchen.",
        price: 450,
        location: "Liido Beach, Mogadishu",
        images: ["https://images.unsplash.com/photo-1499793983690-e29da59ef1c2"],
        category: "Beachfront",
        amenities: ["Wifi", "Pool", "Beach Access", "Kitchen"]
    },
    {
        title: "Luxury Penthouse Suite",
        description: "Experience the height of luxury in this top-floor penthouse with panoramic city views and exclusive amenities.",
        price: 800,
        location: "Hodan District, Mogadishu",
        images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267"],
        category: "Luxury",
        amenities: ["Wifi", "Gym", "Concierge", "Spa"]
    },
    {
        title: "Cozy Wooden Cabin",
        description: "Escape to nature in this charming wooden cabin. Perfect for a quiet retreat surrounded by greenery.",
        price: 120,
        location: "Daynile, Mogadishu",
        images: ["https://images.unsplash.com/photo-1449156493391-d2cfa28e468b"],
        category: "Cabin",
        amenities: ["Wifi", "Fireplace", "Parking"]
    },
    {
        title: "Tropical Island Resort",
        description: "A private island getaway perfect for honeymoons or luxury vacations. Crystal clear waters and white sand.",
        price: 1200,
        location: "Jazeera Beach",
        images: ["https://images.unsplash.com/photo-1573843981267-be1999ff37cd"],
        category: "Islands",
        amenities: ["Wifi", "Pool", "Bar", "Spa"]
    },
    {
        title: "Minimalist Modern Apartment",
        description: "Sleek and stylish apartment in the heart of the city. Close to all major business hubs.",
        price: 200,
        location: "Waberi, Mogadishu",
        images: ["https://images.unsplash.com/photo-1502672260266-1c1ef2d93688"],
        category: "Apartment",
        amenities: ["Wifi", "Workspace", "Air Conditioning"]
    },
    {
        title: "Historic Mansion",
        description: "Stay in a piece of history. This restored mansion offers classic elegance with modern comforts.",
        price: 600,
        location: "Shingani, Mogadishu",
        images: ["https://images.unsplash.com/photo-1564013799919-ab600027ffc6"],
        category: "Mansions",
        amenities: ["Wifi", "Garden", "Library"]
    },
    {
        title: "Glamping Experience",
        description: "Luxury camping under the stars. Enjoy nature without sacrificing comfort.",
        price: 150,
        location: "Outskirts of Mogadishu",
        images: ["https://images.unsplash.com/photo-1523987355523-c7b5b0dd90a7"],
        category: "Camping",
        amenities: ["Wifi", "Firepit", "Breakfast"]
    },
    {
        title: "Avenzel Hotel",
        description: "Top rated hotel with world-class service and amenities.",
        price: 300,
        location: "Airport Road",
        images: ["https://images.unsplash.com/photo-1566073771259-6a8506099945"],
        category: "Hotel",
        amenities: ["Wifi", "Pool", "Gym", "Restaurant"]
    },
    {
        title: "Trending Loft",
        description: "Highly sought after loft space with industrial design. Popular among creatives.",
        price: 180,
        location: "Hamar Weyne",
        images: ["https://images.unsplash.com/photo-1554995207-c18c203602cb"],
        category: "Trending",
        amenities: ["Wifi", "Studio", "Kitchen"]
    },
    {
        title: "Sea View Guest House",
        description: "Affordable guest house with stunning sea views and home-cooked meals.",
        price: 80,
        location: "Xamar Jajab",
        images: ["https://images.unsplash.com/photo-1583037189850-1921ae7c6c22"],
        category: "Guest House",
        amenities: ["Wifi", "Breakfast"]
    }
];

const seedDB = async () => {
    try {
        console.log('Connecting to MySQL...');
        // Test connection
        await db.query('SELECT 1');
        console.log('MySQL Connected.');

        console.log('Clearing existing spaces...');
        await db.query('DELETE FROM spaces');
        // Reset Auto Increment
        await db.query('ALTER TABLE spaces AUTO_INCREMENT = 1');

        console.log('Finding an admin user...');
        const [users] = await db.query("SELECT * FROM users WHERE role = 'admin' LIMIT 1");

        let hostId;
        if (users.length > 0) {
            hostId = users[0].id;
            console.log(`Found Admin: ${users[0].name} (ID: ${hostId})`);
        } else {
            console.log('No Admin user found. Creating a default admin...');
            // Need to create one if checking didn't find one, but user might be using seedSpaces independently
            // Let's just try to find ANY user if no admin
            const [anyUser] = await db.query("SELECT * FROM users LIMIT 1");
            if (anyUser.length > 0) {
                hostId = anyUser[0].id;
                console.log(`No Admin found, using first available User: ${anyUser[0].name} (ID: ${hostId})`);
            } else {
                console.error("No users found in database! Please create a user/admin first.");
                process.exit(1);
            }
        }

        console.log('Seeding spaces...');
        for (const space of spaces) {
            await Space.create({
                ...space,
                host_id: hostId
            });
        }

        console.log(`Successfully seeded ${spaces.length} spaces!`);
        process.exit();
    } catch (error) {
        console.error('Error seeding database:', error);
        process.exit(1);
    }
};

seedDB();
