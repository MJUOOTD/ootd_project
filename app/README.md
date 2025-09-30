# OOTD - Optimal Outfit Tailored by Data

A Flutter mobile application that provides personalized outfit recommendations based on weather conditions and user preferences.

## Features

### ✅ Implemented Features

- **User Onboarding**: Complete profile setup with personal preferences
- **Weather Integration**: Real-time weather data with location services
- **Smart Recommendations**: AI-powered outfit suggestions based on weather and user profile
- **Interactive UI**: Modern, intuitive interface with Material Design 3
- **State Management**: Provider pattern for efficient state management
- **Feedback System**: User feedback collection for recommendation improvement
- **Settings Management**: Comprehensive user preference management
- **Navigation**: Bottom tab navigation with 5 main sections

### 🚧 Planned Features

- **Firebase Integration**: User authentication and cloud data storage
- **Push Notifications**: Weather alerts and outfit reminders
- **Social Features**: Outfit sharing and community recommendations
- **Shopping Integration**: Direct links to purchase recommended items
- **Advanced Analytics**: Usage patterns and recommendation accuracy tracking

## Architecture

### Project Structure

```
lib/
├── models/                 # Data models
│   ├── user_model.dart
│   ├── weather_model.dart
│   ├── outfit_model.dart
│   └── feedback_model.dart
├── providers/              # State management
│   ├── user_provider.dart
│   ├── weather_provider.dart
│   └── recommendation_provider.dart
├── services/               # Business logic
│   ├── weather_service.dart
│   └── recommendation_service.dart
├── screens/                # UI screens
│   ├── splash_screen.dart
│   ├── main_navigation.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── saved_screen.dart
│   ├── notification_screen.dart
│   ├── settings_screen.dart
│   ├── outfit_detail_screen.dart
│   └── onboarding/
│       ├── onboarding_screen.dart
│       └── onboarding_steps/
├── widgets/                # Reusable UI components
│   ├── weather_widget.dart
│   ├── outfit_recommendation_widget.dart
│   └── recommendation_message_widget.dart
└── main.dart
```

### Key Components

#### Models
- **UserModel**: User profile, preferences, and temperature sensitivity
- **WeatherModel**: Weather data with location and conditions
- **OutfitModel**: Outfit details, items, and metadata
- **FeedbackModel**: User feedback and rating system

#### Services
- **WeatherService**: OpenWeatherMap API integration with mock data fallback
- **RecommendationService**: AI algorithm for outfit recommendations

#### Providers (State Management)
- **UserProvider**: User authentication and profile management
- **WeatherProvider**: Weather data fetching and caching
- **RecommendationProvider**: Outfit recommendation management

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ootd_project/app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Configuration

#### Weather API Setup
1. Get an API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Update the API key in `lib/services/weather_service.dart`:
```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
```

#### Firebase Setup (Optional)
1. Create a Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Uncomment Firebase dependencies in `pubspec.yaml`
4. Configure Firebase services in `main.dart`

## Usage

### First Time Setup
1. Launch the app
2. Complete the onboarding process:
   - Basic information (name, email, gender, age)
   - Body type and activity level
   - Temperature sensitivity preferences
   - Style preferences
   - Situation preferences
3. Grant location permissions for weather data

### Daily Usage
1. Open the app to see current weather and recommendations
2. Browse outfit recommendations with swipe navigation
3. Tap on recommendations for detailed view
4. Provide feedback on outfit suggestions
5. Save favorite outfits to your collection

### Settings
- Update personal preferences
- Adjust temperature sensitivity
- Manage style preferences
- Configure notification settings

## Recommendation Algorithm

The recommendation engine considers multiple factors:

1. **Weather Conditions**: Temperature, humidity, wind, precipitation
2. **User Profile**: Gender, age, body type, activity level
3. **Temperature Sensitivity**: Individual cold/heat sensitivity
4. **Style Preferences**: Casual, formal, streetwear, etc.
5. **Situation Context**: Work, casual, date, exercise, travel
6. **Feedback History**: Previous user ratings and adjustments

## API Integration

### Weather Service
- **Primary**: OpenWeatherMap API
- **Fallback**: Mock data for development
- **Features**: Current weather, 5-day forecast, location-based data

### Future Integrations
- Firebase Authentication
- Cloud Firestore for data storage
- Firebase Analytics for usage tracking
- Shopping APIs for outfit items

## Design System

### Colors
- Primary: `#030213` (Dark Blue)
- Secondary: `oklch(0.95 0.0058 264.53)` (Light Blue)
- Background: `#ffffff` (White)
- Muted: `#ececf0` (Light Gray)
- Accent: `#e9ebef` (Gray)

### Typography
- Font Family: SF Pro Display (iOS) / Roboto (Android)
- Base Size: 16px
- Line Height: 1.5
- Weights: Normal (400), Medium (500), Bold (700)

### Components
- Border Radius: 10px
- Elevation: Material Design shadows
- Icons: Material Icons
- Navigation: Bottom tab bar

## Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

### Performance
- Lazy loading for outfit recommendations
- Image caching for outfit photos
- Efficient state management with Provider
- Minimal API calls with proper caching

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@ootd-app.com or create an issue in the repository.

## Roadmap

### Phase 1 (Current)
- ✅ Core recommendation engine
- ✅ User onboarding
- ✅ Weather integration
- ✅ Basic UI/UX

### Phase 2 (Next)
- 🔄 Firebase integration
- 🔄 Push notifications
- 🔄 Enhanced recommendations
- 🔄 Social features

### Phase 3 (Future)
- 📋 Shopping integration
- 📋 Advanced analytics
- 📋 Machine learning improvements
- 📋 Multi-language support

---

**OOTD** - Making outfit decisions effortless, one recommendation at a time.