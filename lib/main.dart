import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'bloc/language_bloc.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'bloc/pharmacy_bloc.dart';
import 'bloc/weather_bloc.dart';
import 'bloc/map_bloc.dart';
import 'bloc/duty_bloc.dart';
import 'bloc/search_bloc.dart';
import 'bloc/favorites_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/admin_analytics_bloc.dart';
import 'bloc/admin_duty_bloc.dart';
import 'bloc/admin_pharmacy_bloc.dart';
import 'bloc/admin_user_bloc.dart';
import 'bloc/government_service_bloc.dart';
import 'services/pharmacy_service.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/firebase_service.dart';
import 'services/favorites_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  await FavoritesService().initialize();
  runApp(const SafrouSmartCityApp());
}

class SafrouSmartCityApp extends StatelessWidget {
  const SafrouSmartCityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: AuthService(),
          )..add(const AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => PharmacyBloc(
            pharmacyService: PharmacyService(),
          )..add(const FetchPharmacies()),
        ),
        BlocProvider(
          create: (context) => WeatherBloc(
            weatherService: WeatherService(),
          )..add(const FetchWeather()),
        ),
        BlocProvider(
          create: (context) => MapBloc(
            pharmacyService: PharmacyService(),
            locationService: LocationService(),
            firebaseService: FirebaseService(),
          ),
        ),
        BlocProvider(
          create: (context) => DutyBloc(
            firebaseService: FirebaseService(),
          )..add(const ListenToDutySchedules()),
        ),
        BlocProvider(
          create: (context) => SearchBloc(),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            favoritesService: FavoritesService(),
          )..add(const LoadFavorites()),
        ),
        BlocProvider(
          create: (context) => AdminAnalyticsBloc(
            firebaseService: FirebaseService(),
          )..add(const FetchAnalytics()),
        ),
        BlocProvider(
          create: (context) => AdminDutyBloc(
            firebaseService: FirebaseService(),
          )..add(const FetchAdminDutySchedules()),
        ),
        BlocProvider(
          create: (context) => AdminPharmacyBloc(
            pharmacyService: PharmacyService(),
          )..add(const FetchAdminPharmacies()),
        ),
        BlocProvider(
          create: (context) => AdminUserBloc(
            authService: AuthService(),
          )..add(const FetchAdminUsers()),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),
        BlocProvider(
          create: (context) => GovernmentServiceBloc(
            firebaseService: FirebaseService(),
          )..add(const FetchGovernmentServices()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, langState) {
          return MaterialApp(
            title: 'Pharmacy Radar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: Locale(langState.languageCode),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
