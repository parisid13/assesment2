# Flutter To-Do App

This Flutter application is a simple To-Do list manager that supports user authentication, light/dark mode, and CRUD operations using SQLite. It also utilizes SharedPreferences to save the last data and employs an in-memory list for the user interface.

## Features

- **User Authentication**: Users can log in to access their To-Do list.
- **Light/Dark Mode**: The app supports both light and dark themes for better user experience.
- **CRUD Operations**: Users can create, read, update, and delete activities.
- **Persistent Storage**: Last data is saved using SharedPreferences.
- **In-Memory List**: Activities are displayed using an in-memory list for quick access.

## Project Structure

```
flutter_todo_app
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── app.dart                 # Main application widget with theme and routes
│   ├── theme.dart               # Defines light and dark themes
│   ├── models
│   │   └── activity.dart        # Activity model class
│   ├── providers
│   │   └── activity_provider.dart # State management for activities
│   ├── services
│   │   ├── db_service.dart      # Handles SQLite CRUD operations
│   │   └── prefs_service.dart   # Manages SharedPreferences
│   ├── repositories
│   │   └── activity_repository.dart # Intermediary for CRUD operations
│   └── pages
│       ├── login_page.dart      # User login interface
│       └── home_page.dart       # Displays the list of activities
├── pubspec.yaml                 # Flutter project configuration
├── .gitignore                   # Files to ignore in version control
├── analysis_options.yaml        # Dart analysis options
├── test
│   └── widget_test.dart         # Widget tests for the application
└── README.md                    # Project documentation
```

## Getting Started

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd flutter_todo_app
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Run the application**:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.