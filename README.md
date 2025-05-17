# 📝 My Note App

A simple yet powerful note-taking application built using Flutter and Firebase. This app demonstrates key Flutter concepts and Firebase integration, ideal for teaching basic to intermediate Flutter development.

---

## 🚀 Features

- Firebase Authentication (Login & Register)
- Create Notes
- View Notes
- Edit Notes
- Delete Notes
- Responsive UI
- Organized Project Structure
- Error Handling with Snackbars

---

## 🛠️ Technologies Used

- Flutter
- Firebase
- Dart
- Provider
- Material Design

---

## 📦 Setup Instructions

1. Clone this repository:
    ```bash
    git clone https://github.com/your-username/my_note_app.git
    cd my_note_app
    ```
2. Install dependencies:
    ```bash
    flutter pub get
    ```
3. Setup Firebase:
    1. Create a Firebase project at https://console.firebase.google.com
    2. Add your Android/iOS app
    3. Download the google-services.json or GoogleService-Info.plist
    4. Run:
    ```bash
    flutterfire configure
    ```
    5. Ensure lib/firebase_options.dart is generated
4. Run the app:
    ```bash
    flutter run
    ```
---

## ⚠️ Note
Don’t forget to add firebase_options.dart to your .gitignore for security:<br>
    ```
lib/firebase_options.dart
    ```

---

## 👨‍🏫 Educational Goals
This app is designed by learning following things:
1. Building UI with Flutter Widgets
2. Navigation with named routes
3. Firebase Authentication integration
4. Real-time data handling with Firestore
5. Best practices for clean Flutter code