# Infographic Generator

An AI-powered Flutter app that generates beautiful infographics using Google Gemini AI. Create stunning visual content with just a text prompt!

## Features

- 🤖 **AI-Powered Generation**: Uses Google Gemini AI to create professional infographics
- 🎨 **Beautiful Design**: Modern, responsive designs with attractive visual elements
- ✏️ **Editable Content**: Edit text elements directly in the generated infographic
- 📱 **Cross-Platform**: Works on Android, iOS, and Web
- 💾 **PNG Export**: Download your infographic as a high-quality PNG image
- 🎯 **GetX Pattern**: Clean architecture with GetX state management

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Google Gemini API Key

### 2. Get Google Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the API key

### 3. Configure API Key
1. Open `lib/app/data/services/gemini_service.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
```dart
static const String _apiKey = 'your_actual_api_key_here';
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

## How to Use

1. **Enter a Prompt**: Type what you want to create an infographic about
   - Example: "Climate change statistics and solutions"
   - Example: "Benefits of renewable energy"
   - Example: "Digital marketing trends 2024"

2. **Generate**: Tap "Generate Infographic" and wait for AI to create your design

3. **Edit**: Tap on any text element in the infographic to edit it

4. **Download**: Tap the download button to save as PNG

## Project Structure

```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   │   └── infographic_model.dart
│   │   └── services/
│   │       └── gemini_service.dart
│   ├── modules/
│   │   ├── home/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   └── infographic_viewer/
│   │       ├── bindings/
│   │       ├── controllers/
│   │       └── views/
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
└── main.dart
```

## Dependencies

- `get: ^4.7.2` - State management and routing
- `google_generative_ai: ^0.4.3` - Google Gemini AI integration
- `flutter_inappwebview: ^6.0.0` - HTML/CSS rendering
- `screenshot: ^2.1.0` - Screenshot capture
- `path_provider: ^2.1.1` - File system access
- `permission_handler: ^11.0.1` - Device permissions
- `http: ^1.1.0` - HTTP requests

## Permissions

The app requires the following permissions:
- Internet access (for AI API calls)
- Storage access (for downloading images)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
