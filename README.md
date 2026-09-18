# Apna Master Admin Panel

A secure, responsive Flutter Web application for managing software client licenses, device bindings, demo periods, and validity cycles in a 3-Tier licensing ecosystem.

---

## 🚀 Key Features

- **Master Admin Authentication**: Secure login against Master Admin profiles scoped by unique `masterCode`.
- **Dynamic 3-Tier Licensing**:
  - **3-Day Demo Cycle**: New users receive an automatic 3-day demo period (`isDemo`).
  - **30-Day Production Cycle**: Transition users to production or extend their validity for 30 days (`isProduction`).
  - **Dynamic State Engine**: All statuses (`DEMO`, `PRODUCTION`, `EXPIRED`, `STOPPED`) are computed dynamically from timestamps without storing redundant or mutable status flags.
- **Hardware Binding & Reset**: Real-time display of bound device IDs with single-click hardware reset so clients can switch machines seamlessly.
- **Access Control (Stop / Resume)**: Instantly suspend or resume user access via the `stop` flag.
- **Granular Filtering & Search**: Instant reactive search by user ID, password, or device ID, with filter pills for **All**, **Demo**, **Production**, **Expired**, and **Stopped**.
- **Real-Time Analytics**: Dashboard with dynamic donut charts and metrics for total, active demo, active production, expired, and stopped users.

---

## 🛠️ Tech Stack & Architecture

- **Frontend**: Flutter Web (Dart 3.x)
- **State Management & Routing**: GetX with full reactive streams (`RxList`, `Obx`, `GetxController`)
- **Backend & Database**: Firebase Firestore & Firebase Auth
- **Styling & Theme**: Modern Dark Glassmorphism UI with responsive multi-column layouts

---

## 🔒 Security & Rules

- **Deny-by-default Architecture**: All Firestore collections and Storage paths are closed by default.
- **Strict Master Code Isolation**: Queries and mutations are enforced at the database layer using `resource.data.masterCode == getAdminMasterCode()`.
- **Tamper-Proof Duration Enforcement**: Firestore rules prevent manipulating timestamp durations outside allowed periods (3 days for demo, 30 days for production).
- **Zero Credentials Exposure**: No private keys or service accounts in frontend builds; source maps disabled in release builds.

---

## 📦 Getting Started

### Prerequisites
- Flutter SDK (3.x or later)
- Chrome / Chromium-based browser

### Run Development
```bash
flutter pub get
flutter run -d chrome
```

### Run Tests
```bash
flutter test
```

### Build Production Web App
```bash
flutter build web --release --no-source-maps
```

