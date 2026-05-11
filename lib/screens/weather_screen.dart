import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/language_bloc.dart';
import '../services/translation_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentGreen,
            ),
          );
        } else if (state is WeatherLoaded) {
          final weather = state.weather;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentWeatherCard(weather, l),
                const SizedBox(height: 24),
                _buildWeatherDetailsGrid(weather, l),
                const SizedBox(height: 24),
                Text(
                  Translations.getText('forecast', l),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildForecastList(weather),
              ],
            ),
          );
        } else if (state is WeatherError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(state.message, style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<WeatherBloc>().add(const RefreshWeather()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrentWeatherCard(dynamic weather, String l) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.royalPurple.withOpacity(0.8),
            AppTheme.primaryGreen.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.getText('location', l),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.mountainWhite.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toInt()}°',
                    style: GoogleFonts.poppins(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    weather.condition,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.wb_cloudy_outlined, size: 80, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${Translations.getText('feels_like', l)} ${weather.feelsLike.toInt()}°',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGrid(dynamic weather, String l) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildWeatherDetailCard(Translations.getText('humidity', l), '${weather.humidity.toInt()}%', Icons.opacity),
        _buildWeatherDetailCard(Translations.getText('wind_speed', l), '${weather.windSpeed.toInt()} km/h', Icons.air),
        _buildWeatherDetailCard(Translations.getText('uv_index', l), '${weather.uvIndex}', Icons.wb_sunny),
        _buildWeatherDetailCard(Translations.getText('visibility', l), '${weather.visibility.toInt()} km', Icons.visibility),
      ],
    );
  }

  Widget _buildWeatherDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.accentGreen, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildForecastList(dynamic weather) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.forecast.length,
        itemBuilder: (context, index) {
          final day = weather.forecast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day.day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Icon(Icons.wb_sunny_outlined, color: AppTheme.accentGreen, size: 24),
                const SizedBox(height: 8),
                Text('${day.high.toInt()}° / ${day.low.toInt()}°', style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }
}
