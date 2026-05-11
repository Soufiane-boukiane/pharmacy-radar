# API Integration Guide

## 🔑 Getting API Keys

### 1. Google Places API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable "Places API"
4. Create an API key (Credentials → Create Credentials → API Key)
5. Replace `YOUR_GOOGLE_PLACES_API_KEY` in `lib/services/pharmacy_service.dart`

### 2. OpenWeatherMap API
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Get your API key from the account settings
4. Replace `YOUR_OPENWEATHER_API_KEY` in `lib/services/weather_service.dart`

## 📁 Project Structure

```
lib/
├── models/
│   ├── pharmacy.dart       # Pharmacy data model
│   └── weather.dart        # Weather data model
├── services/
│   ├── pharmacy_service.dart   # Google Places API integration
│   └── weather_service.dart    # OpenWeatherMap API integration
├── bloc/
│   ├── pharmacy_bloc.dart      # Pharmacy state management
│   └── weather_bloc.dart       # Weather state management
└── screens/
    ├── pharmacy_screen.dart    # Updated with Bloc
    └── weather_screen.dart     # Updated with Bloc
```

## 🚀 Features Implemented

### Pharmacy Service
- ✅ Fetch nearby pharmacies using Google Places API
- ✅ Get pharmacy details (name, address, phone, hours, rating)
- ✅ Mock data fallback for testing
- ✅ Duty pharmacy detection

### Weather Service
- ✅ Current weather data from OpenWeatherMap
- ✅ 5-day forecast
- ✅ Weather details (humidity, wind, UV index, visibility)
- ✅ Mock data fallback

### State Management (Bloc)
- ✅ PharmacyBloc for pharmacy data management
- ✅ WeatherBloc for weather data management
- ✅ Loading, Loaded, and Error states
- ✅ Refresh functionality

### UI Updates
- ✅ Pharmacy screen now uses Bloc
- ✅ Weather screen now uses Bloc
- ✅ Error handling with retry buttons
- ✅ Loading indicators

## 🔧 Next Steps

1. **Map Integration**
   - Implement flutter_map with OpenStreetMap
   - Add pharmacy markers on map
   - Add location services

2. **Firebase Setup**
   - Set up Firebase project
   - Create Firestore database for duty system
   - Real-time duty pharmacy updates

3. **Additional Features**
   - Prayer times integration
   - Emergency services
   - Tourism attractions
   - Local services directory

## 📝 Testing

To test with mock data:
1. The services automatically fall back to mock data if API calls fail
2. No API keys needed for initial testing
3. Replace API keys when ready for production

## ⚠️ Important Notes

- Keep API keys secure (use environment variables in production)
- Google Places API has usage limits (free tier: 25,000 requests/month)
- OpenWeatherMap free tier: 60 calls/minute
- Consider implementing caching to reduce API calls
