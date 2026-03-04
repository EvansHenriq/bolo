# 🍰 Bolo - Bakery Management App

> Aplicativo offline para gestão de pedidos, clientes e produtos de confeitaria.

A mobile bakery management app built with Flutter for a local confectionery business. Manage products, clients, and orders — all offline with local SQLite storage.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-2.17+-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## About the Project

**Bolo** was developed as a capstone project (TCC, 2022) to solve real inventory and order tracking needs for a small bakery. The app runs entirely offline, storing all data locally via SQLite.

### Features

- **Product Management** — Full CRUD with photo capture from camera or gallery
- **Client Management** — Register and manage customer information
- **Order Management** — Create orders linking clients and products with quantities
- **Image Support** — Product photos stored as Base64 in the local database
- **Brazilian Locale** — Currency formatting (R$), date formats, and input masks for CPF/phone
- **Material Design 3** — Clean, modern UI with custom color scheme
- **Offline-First** — No internet required; all data persists locally with SQLite

## Screenshots

| Products | Product Form | Orders |
|:--------:|:------------:|:------:|
|  <img width="320" height="480" alt="Products" src="https://github.com/user-attachments/assets/240cfcf8-9ab8-42d0-975d-1131bf08e1c7" /> | <img width="320" height="480" alt="Product Form" src="https://github.com/user-attachments/assets/4562789e-dc93-4e10-843a-1242ab8c14e2" /> | <img width="320" height="480" alt="Orders" src="https://github.com/user-attachments/assets/41a90d09-67cd-403a-b354-e23555bb82e0" /> |

## Built With

| Technology | Purpose |
|---|---|
| **Flutter** 3.0+ | Cross-platform mobile framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **sqflite** | Local SQLite database |
| **image_picker** | Camera and gallery photo capture |
| **path_provider** | File system access |
| **intl** | Internationalization and date formatting |
| **extended_masked_text** | Input masks (CPF, phone, currency) |
| **Equatable** | Value equality for models |
| **Material Design 3** | UI design system |

## Architecture

The project follows **Clean Architecture** with feature-based organization:

```
lib/
├── core/
│   ├── database/          # SQLite database helper and table definitions
│   ├── theme/             # Material Design 3 theme configuration
│   ├── utils/             # Currency and date formatters
│   └── widgets/           # Shared widgets (empty state, loading)
├── features/
│   ├── client/
│   │   ├── data/          # Data source, model, repository
│   │   └── presentation/  # Pages, providers
│   ├── home/
│   │   └── presentation/  # Tab navigation, dashboard
│   ├── order/
│   │   ├── data/          # Data source, models, repository
│   │   └── presentation/  # Pages, providers
│   ├── product/
│   │   ├── data/          # Data source, model, repository
│   │   └── presentation/  # Pages, providers
│   └── splash/
│       └── presentation/  # Splash screen
├── app.dart               # MaterialApp configuration
└── main.dart              # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio (for Android) or Xcode (for iOS)

### Installation

```bash
# Clone the repository
git clone https://github.com/EvansHenriq/bolo.git
cd bolo

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Challenges & Solutions

### 1. Image Storage with Base64 Encoding

Storing product photos required choosing between file system storage and database embedding. File paths break when the app data directory changes, and managing separate image files adds complexity.

**Solution:** Images are converted to Base64 strings and stored directly in the SQLite database. This keeps all data self-contained in a single database file, simplifying backup and data integrity at the cost of slightly larger storage.

### 2. Complex Relationships in SQLite

Orders reference both clients and products, with each order containing multiple items with quantities. Managing these relationships without an ORM required careful SQL design.

**Solution:** Three-table design with `orders`, `order_items`, and foreign keys linking to `clients` and `products`. The repository layer handles JOIN queries and maps results into nested Dart objects, keeping the presentation layer clean.

### 3. Brazilian Currency and Input Formatting

Handling BRL currency formatting (R$ 1.234,56) with real-time input masks for CPF and phone numbers required custom parsing logic, since standard formatters default to US/EU patterns.

**Solution:** Combined the `extended_masked_text` package for CPF/phone masks with the `intl` package configured for `pt_BR` locale, ensuring consistent formatting across all monetary and document fields.

## Future Improvements

- [ ] Data export/import (JSON or CSV backup)
- [ ] Sales reports and dashboard analytics
- [ ] Cloud sync option (Firebase) for multi-device support
- [ ] Migration from Provider to Riverpod for improved state management
- [ ] Unit and widget test coverage

## Author

**Evandro Henrique** — Flutter Developer

- GitHub: [@EvansHenriq](https://github.com/EvansHenriq)
- LinkedIn: [linkedin.com/in/evandro-henrique](https://linkedin.com/in/evandro-henrique)

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
