# Rick and Morty Character Explorer

A professional Flutter application demonstrating a robust, offline-first architecture for exploring the Rick and Morty universe. This project was built to meet the "Gold Standard" for technical interviews.

## 🚀 Key Features

### Core Requirements
- **Infinite Scrolling**: Browsable character list with seamless pagination (800+ characters).
- **Character Details**: Comprehensive view of status, species, origin, and location.
- **Persistent Favorites**: Star your favorite characters; choices are saved locally via SQLite.
- **Local Editing (Override)**: Edit character details locally. The app uses a sophisticated merging strategy to favor local user edits over live API data.
- **Offline-First Resilience**: Persistent caching of all characters. The app functions perfectly without an internet connection, falling back to local storage.

### Bonus Features
- **Real-time Search**: Debounced search bar to filter characters by name.
- **Reset to API Data**: One-tap restoration of original character data, clearing local overrides.
- **Advanced Design System**: Centralized typography (`AppText`) and colors (`AppColors`) for absolute visual consistency and responsiveness.
- **API Rate-Limit Handling**: Exponential backoff strategy for 429 errors during image loading.

## 🛠 Tech Stack

- **State Management**: [Riverpod](https://riverpod.dev/) (Notifier & AsyncNotifier) for reactive, testable state.
- **Persistence**: [Sqflite](https://pub.dev/packages/sqflite) for robust local SQL storage.
- **Networking**: [http](https://pub.dev/packages/http) for lightweight API communication.
- **Animations**: Hero transitions and shimmer-like loading states.
- **Design**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil) for a pixel-perfect responsive UI.

## 🏗 Architecture

The project follows a **Feature-First Architecture**, ensuring high modularity and separation of concerns:

- `core/`: Shared models, database helpers, network clients, and design system (widgets/utils).
- `features/`:
  - `home/`: Character listing and search.
  - `details/`: In-depth character information.
  - `favorites/`: Persistent collection management.
  - `editing/`: Local override logic and forms.

### Data Merging Strategy
The application maintains two data sources:
1. **Live/Cached API Table**: The "ground truth" from the server.
2. **Local Edits Table**: User-defined overrides.

At runtime, the `Character` model uses a `mergeWithEdits` method to produce a final representation, ensuring that user customizations are always prioritized across the entire UI.

## 🏁 Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd rickandmorty
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 🧪 Testing

The project includes unit tests for core business logic, specifically the character data merging mechanism.

```bash
flutter test
```

---
*Created with ❤️ for the Rick and Morty Fan Community.*
