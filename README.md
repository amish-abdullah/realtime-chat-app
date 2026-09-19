# 💬 Chat App

A modern **real-time messaging application** built with **Flutter and Firebase**.

This project is designed to provide a smooth and interactive chat experience with real-time messaging, user authentication, typing indicators, message read receipts, and voice & video calling.

## ✨ Features

* 🔐 **User Authentication**

  * User registration
  * Login
  * Forgot password
  * Secure Firebase Authentication

* 💬 **Real-Time Messaging**

  * Send and receive messages in real time
  * Firebase Cloud Firestore integration
  * Individual one-to-one conversations

* ✍️ **Typing Indicator**

  * Shows when the other user is typing
  * Real-time typing status

* ✓✓ **Message Read Receipts**

  * Sent messages
  * Read messages
  * Double-tick read status

* 📞 **Voice & Video Calling**

  * Voice calling
  * Video calling
  * Real-time call invitations

* 👤 **Contacts**

  * View available users
  * Start conversations directly from contacts

* 🔔 **Notifications**

  * Local notifications for new messages

* ⚙️ **Settings**

  * Account settings
  * Logout functionality

* 🎨 **Modern UI**

  * Clean and responsive interface
  * WhatsApp-inspired chat experience

## 🛠️ Technologies Used

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Cloud Firestore**
* **Flutter Local Notifications**
* **ZEGOCLOUD**
* **Android**

## 🏗️ Architecture & Core Components

The application is structured into different parts to keep the code organized and maintainable.

### Authentication

Firebase Authentication is used to handle:

* User registration
* User login
* Password recovery
* User session management

### Messaging

**Cloud Firestore** is used for real-time chat functionality.

The application supports:

* Real-time messages
* Typing status
* Message status
* Read receipts
* Chat tracking

### Calling

**ZEGOCLOUD** is integrated to provide real-time voice and video calling functionality.

## 🔄 How It Works

1. A user creates an account or logs in.
2. Firebase Authentication manages the user's session.
3. Users can find other registered users through the app.
4. A chat can be started with another user.
5. Messages are stored and synchronized through Cloud Firestore.
6. Typing status and message read status are updated in real time.
7. Users can initiate voice or video calls from the chat screen.
8. Local notifications can alert users when a new message is received.

## 🚀 Getting Started

### Prerequisites

Make sure you have Flutter and Android development tools installed.

Check your Flutter installation:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/chat_app.git
```

Navigate to the project:

```bash
cd chat_app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## 🔥 Firebase Configuration

This application requires a Firebase project for authentication and Firestore functionality.

Before running the project, configure Firebase for your Android application.

You will need to add your Firebase configuration files and configure the required Firebase services.

## 📞 Calling Configuration

The calling functionality uses **ZEGOCLOUD**.

To enable voice and video calling, configure your own ZEGOCLOUD credentials and required calling settings.

> Do not upload private API keys, App Secrets, or other sensitive credentials to a public GitHub repository.

## 📚 What I Learned

This project helped me practice and understand:

* Flutter application development
* Firebase Authentication
* Cloud Firestore
* Real-time database operations
* Building a real-time chat system
* Managing user sessions
* Typing indicators
* Read receipts
* Local notifications
* Voice and video calling integration
* Navigation and application state management
* Building a multi-screen Flutter application

## 🔮 Future Improvements

Planned improvements include:

* 🖼️ Image and video sharing
* 🎤 Voice messages
* 📎 File sharing
* 👥 Group chats
* 🟢 Online/offline status
* 🔔 Push notifications with Firebase Cloud Messaging
* 🔎 Chat search
* 🗑️ Delete and edit messages
* 🌙 Dark mode
* 👤 Profile customization

## 👨‍💻 About

This project was developed as a Flutter learning and portfolio project, with a focus on **real-time communication, Firebase integration, and modern mobile application development**.
