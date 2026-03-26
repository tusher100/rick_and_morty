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

- **State Management**: [Riverpod](https://riverpod.dev/) (Notifier & AsyncNotifier).
  - *Reasoning*: We chose Riverpod for its compile-time safety, seamless handling of asynchronous data, and the ability to easily mock providers for unit testing.
- **Persistence**: [Sqflite](https://pub.dev/packages/sqflite) for robust local SQL storage.
  - *Reasoning*: Chosen for its ability to handle complex relational data (merging API results with local overrides) and high performance for long character lists.
- **Networking**: [http](https://pub.dev/packages/http).
- **Animations**: Hero transitions and shimmering skeleton loaders.
- **Design**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil) for a pixel-perfect responsive UI with custom `AppText` and `AppColors` systems.

## 🏗 Architecture

The project follows a **Feature-First Architecture**, ensuring high modularity and separation of concerns:

- `core/`: Shared models, database helpers, network clients, and design system (widgets/utils).
- `features/`:
  - `home/`: Character listing, search, and sophisticated filtering.
  - `details/`: In-depth character information with Hero animations.
  - `favorites/`: Persistent collection management.
  - `editing/`: Local override logic and reactive forms.

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

## ⚠️ Known Limitations

- **Plugin Cold Boot**: Because the app uses the `connectivity_plus` native plugin, a **full cold restart** (`flutter run`) is required after the initial build. A hot reload/restart may trigger a `MissingPluginException` until the native bits are linked.
- **Filtered Caching**: While the main character list is cached offline, specific complex combinations of search queries and filters are currently fetched live and not yet cached deep in the local database.
- **Image Persistence**: Images rely on `cached_network_image`. While they are cached once loaded, they are not stored in the SQLite database as blobs (which is a deliberate choice for performance and database size).

## 🧪 Testing

The project includes unit tests for the core data merging logic.

```bash
flutter test
```