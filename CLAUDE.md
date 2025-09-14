# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
# Run the app
flutter run

# Build for specific platforms
flutter build apk          # Android APK
flutter build ios          # iOS build
flutter build macos        # macOS build

# Code generation (required after modifying Freezed models)
flutter pub run build_runner build --delete-conflicting-outputs

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Architecture

This Flutter music app follows **Clean Architecture** with a feature-based organization:

### Core Architecture Patterns
- **Repository Pattern**: All data operations go through repositories (`MusicRepository`, `PlaylistRepository`)
- **Provider Pattern**: Riverpod for state management and dependency injection
- **Freezed Models**: Immutable data classes with JSON serialization for API models

### Data Flow
1. **UI Layer** → Riverpod Providers → **Repository Layer** → **Data Sources** (API/Database)
2. **Playback**: UI → `PlaybackService` → `just_audio` package
3. **Local Storage**: Playlists → `PlaylistRepository` → SQLite via `sqflite`

### Key Services and Their Responsibilities

**PlaybackService** (`lib/src/data/services/playback_service.dart`):
- Manages audio playback using `just_audio`
- Exposes reactive streams for player state
- Handles playlist management and song transitions

**MusicRepository** (`lib/src/data/repositories/music_repository.dart`):
- Abstracts music data operations
- Supports multiple API sources (GdApiService, ApiService)
- Provides search and song retrieval functionality

**Database Schema**:
- `playlists` table: Stores playlist metadata
- `playlist_songs` table: Links songs to playlists
- Version 5 with migration support

### API Integration

Two API sources are configured:
1. **Primary**: `https://music-api.gdstudio.xyz` (Kuwo source)
2. **Secondary**: `http://tangdou.space:58000` (Custom backend)

APIs are accessed through the repository pattern, allowing easy switching between sources.

### State Management Structure

Global providers in `lib/src/data/providers.dart`:
- `musicRepositoryProvider`: Music data operations
- `playlistRepositoryProvider`: Local playlist management
- `pageIndexProvider`: Bottom navigation state

Feature-specific providers are located within each feature directory.

## Project Structure

```
lib/src/
├── data/           # Data layer (models, repositories, services, sources)
├── features/       # Feature modules (home, search, library, player, lyrics)
└── shared/         # Shared components (shell, theme)
```

Each feature follows the pattern:
- `presentation/pages/`: Full-screen pages
- `presentation/widgets/`: Reusable components
- `presentation/providers/`: Feature-specific state

## Important Implementation Details

### Adding New Features
1. Create a new directory under `lib/src/features/`
2. Follow the existing feature structure (presentation/pages, presentation/widgets)
3. Add navigation in `lib/src/shared/shell/shell.dart` if needed
4. Create feature-specific providers for state management

### Modifying Data Models
1. Update the model in `lib/src/data/models/`
2. If using Freezed, run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update repository methods if needed
4. Ensure JSON serialization is properly configured

### Working with the Music Player
- Player state is managed by `PlaybackService`
- Use the exposed streams for reactive UI updates
- Player controls should interact through the service methods
- Lyrics synchronization is handled automatically when lyrics are available

### Database Migrations
- Current version: 5
- Migrations are handled in `lib/main.dart`
- Add new migrations to the `_onUpgrade` function
- Test migrations thoroughly before incrementing version