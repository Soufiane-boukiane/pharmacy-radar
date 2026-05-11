# 🎯 Pharmacy Radar 

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-State_Management-blueviolet?style=for-the-badge)

**Pharmacy Radar** is a premium, open-source smart city application designed to help citizens locate duty pharmacies, public services, and emergency contacts in real-time. Built with Flutter and Firebase, it features a highly dynamic mapping system, modern UI aesthetics (Glassmorphism), and an intelligent "Auto-Duty Engine".

---

## ✨ Key Features

*   **🤖 Automated Duty Engine:** Automatically calculates and updates the status of pharmacies (Open, Closed, Day Duty, Night Duty) based on real-time server timestamps and shift configurations.
*   **🗺️ Advanced 2D & 3D Mapping:** Interactive maps featuring dynamic "Radar" markers, custom styling, and seamless navigation. Includes an experimental **3D Simulation Mode** powered by MapLibre.
*   **🌍 Multi-Language Support:** Fully localized in English, Arabic, French, and Spanish with seamless RTL/LTR switching.
*   **🛡️ Secure Admin Portal:** A built-in, secure dashboard for administrators to add, edit, and manage pharmacies and their schedules without writing code.
*   **🎨 Premium UI/UX:** Designed with deep dark modes, glassmorphic floating cards, micro-animations, and carefully crafted typography.
*   **🏛️ Public Services:** Built-in directory for hospitals, police stations, and fire departments with direct routing.

---

## 📸 Screenshots

*(Replace these placeholders with actual screenshots of your app)*

| Home Dashboard | Interactive Map | Pharmacy Directory | 3D Simulation |
|:---:|:---:|:---:|:---:|
| <img src="https://via.placeholder.com/200x400" width="200"/> | <img src="https://via.placeholder.com/200x400" width="200"/> | <img src="https://via.placeholder.com/200x400" width="200"/> | <img src="https://via.placeholder.com/200x400" width="200"/> |

---

## 🛠️ Tech Stack & Architecture

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **Backend:** [Firebase](https://firebase.google.com/) (Firestore, Firebase Auth)
*   **State Management:** BLoC / Cubit Pattern
*   **Mapping Services:** `flutter_map`, `maplibre_gl`, ArcGIS Imagery Tiles.
*   **Routing & Navigation:** Native Flutter Navigator / URL Launcher for Maps integration.

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher recommended)
*   [Firebase CLI](https://firebase.google.com/docs/cli) installed and logged in.
*   An active [Firebase Project](https://console.firebase.google.com/).

### 1. Clone the repository
```bash
git clone https://github.com/YOUR-USERNAME/pharmacy-radar.git
cd pharmacy-radar
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. 🔥 Firebase Setup (CRITICAL)
For security reasons, the original Firebase configuration files have been anonymized. You **must** connect this app to your own Firebase project to make it work.

1. Open your terminal in the project root.
2. Run the FlutterFire CLI to generate your configuration:
```bash
flutterfire configure
```
3. Select your Firebase project (or create a new one) and choose the platforms (Android, iOS, Web).
4. The CLI will automatically generate a valid `lib/firebase_options.dart` and `google-services.json` / `GoogleService-Info.plist` for you.

### 4. Firestore Database Structure
To ensure the app reads data correctly, your Firestore database should contain the following collections:
*   `pharmacies`: (Documents containing fields like `name`, `address`, `latitude`, `longitude`, `phone`, `scheduleType`, `autoMode`).
*   `users`: (For Admin authentication and role management).
*   `government_services`: (For public services markers).

### 5. Run the app
```bash
flutter run
```

---

## 👨‍💻 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ for better Smart Cities.*
