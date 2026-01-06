# HoySpace Booking App

Node.js Backend + Flutter Mobile App Project for Course Assessment.

## Project Overview
This system is a complete backend system using Node.js/Express, exposed through RESTful APIs, and consumed by a Flutter mobile application. It facilitates space booking (hotels, rooms, etc.) with a full Admin Portal for management.

## Features

### User Features
- **Registration/Login**: Secure JWT-based authentication.
- **Discover Spaces**: Browse available spaces.
- **Book Spaces**: Make bookings for specific dates.
- **Manage Bookings**: View and cancel personal bookings.
- **Profile**: manage user profile.

### Admin Features
- **Admin Dashboard**: Mobile-integrated admin portal.
- **User Management**: View and delete users.
- **Space Management**: Create, Read, Update, Delete (CRUD) spaces.
- **Booking Management**: View all bookings, confirm or cancel them.

## Technology Stack
- **Backend**: Node.js, Express.js, MongoDB (Mongoose), JWT, Nodemailer.
- **Frontend**: Flutter (Mobile).
- **Tools**: Git, Jira (for project management).

## Setup Instructions

### Backend
1. Navigate to `backend` folder.
2. Install dependencies: `npm install`.
3. Create `.env` file based on `.env.example`.
4. Run server: `npm run dev` (development) or `npm start`.

### Mobile App
1. Navigate to `mobile_app` folder.
2. Install dependencies: `flutter pub get`.
3. Update `lib/core/constants.dart` if testing on physical device (replace `10.0.2.2` with your IP).
4. Run app: `flutter run`.

## API Endpoints
- **Auth**: `/api/auth/register`, `/api/auth/login`
- **Users**: `/api/users` (Admin)
- **Spaces**: `/api/spaces` (CRUD)
- **Bookings**: `/api/bookings` (CRUD)

## Group Members
1. [Name] - [ID]
2. [Name] - [ID]
3. [Name] - [ID]
4. [Name] - [ID]
5. [Name] - [ID]
