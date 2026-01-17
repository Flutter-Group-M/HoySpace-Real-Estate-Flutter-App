# 🏨 HoySpace Booking App

> A modern, full-stack mobile application for booking spaces, hotels, and apartments. Built with **Flutter**, **Node.js**, and **MySQL**.

![Home Screen](Screenshot_20260107_021232_WPS%20Office.jpg)

## 🚀 Project Overview

**HoySpace** is a complete booking system designed for seamless user experiences and robust administration. It features a beautiful Flutter mobile app for users to discover and book distinct spaces, backed by a powerful Node.js/Express API that manages users, bookings, payments, and real-time messaging.

## ✨ Key Features

### 👤 User Application
- **Auth System**: Secure Registration & Login with JWT Authentication.
- **Discover**: 
  - **Location Search**: Find spaces in Mogadishu, Hargeisa, Bosaso, etc.
  - **Keyword Search**: Search for "Villa", "Beach", "Pool" globally.
  - **Categories**: Filter by Hotel, Apartment, Cabin, Luxury, etc.
- **Space Details**: View high-quality images, amenities, host info, and reviews.
- **Booking Flow**: Select dates, calculate price, and secure your booking.
- **Real-time Chat**: Message hosts directly within the app.
- **Profile**: Manage your data, view booking history, and save favorite spaces.
- **Dark/Light Mode**: Optimized UI for any lighting (Default: Premium Dark/Gold Theme).

### 🛡️ Admin Dashboard
- **Mobile Admin Portal**: Fully integrated admin view accessible within the app.
- **Stats Overview**: Real-time polling of total bookings and revenue.
- **User Management**: View, Ban, or Delete users.
- **Space Management**: Add new spaces, upload images, and edit details.
- **Booking Control**: View all active bookings, status updates, and cancellations.

## 🛠️ Technology Stack

### Mobile App (Frontend)
- **Framework**: Flutter (Dart)
- **State Management**: GetX & Provider
- **UI Components**: BottomNavyBar, ZoomDrawer, Custom Fonts (Google Fonts)
- **Networking**: HTTP, Shared Preferences

### Backend (API)
- **Runtime**: Node.js & Express.js
- **Database**: MySQL (via `mysql2` driver)
- **Authentication**: JSON Web Tokens (JWT) & Bcrypt
- **Image Handling**: JSON storage for multi-image arrays

## 📸 Screenshots

| Home & Discover | Admin Dashboard |
|:---:|:---:|
| ![Home](Screenshot_20260107_021232_WPS%20Office.jpg) | ![Admin](Screenshot_20260107_021237_WPS%20Office.jpg) |

## ⚙️ Setup Instructions

### 1. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Configure Database
# Import the schema.sql file into your MySQL database

# Create .env file
# PORT=3000
# DB_HOST=localhost
# DB_USER=root
# DB_PASS=yourpassword
# DB_NAME=hoyspace_db
# JWT_SECRET=yoursecretkey

# Run the server
npm run dev
```

### 2. Mobile App Setup
```bash
# Navigate to mobile app directory
cd mobile_app

# Install dependencies
flutter pub get

# Run the app
# Ensure your backend IP is correctly set in lib/core/constants.dart
flutter run
```

## 🔗 API Documentation
- **Base URL**: `http://localhost:3000/api`
- **Auth**: `POST /auth/login`, `POST /auth/register`
- **Spaces**: `GET /spaces` (Supports `?search=` & `?location=`), `POST /spaces`
- **Bookings**: `GET /bookings`, `POST /bookings`

## 👥 Contributors
- **Sharmake** - *Lead Developer*
