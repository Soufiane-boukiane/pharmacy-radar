import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../bloc/government_service_bloc.dart';
import '../bloc/language_bloc.dart';
import '../models/government_service.dart';

class GovernmentMapScreen extends StatefulWidget {
  const GovernmentMapScreen({Key? key}) : super(key: key);

  @override
  State<GovernmentMapScreen> createState() => _GovernmentMapScreenState();
}

class _GovernmentMapScreenState extends State<GovernmentMapScreen> {
  GovernmentService? _selectedService;
  late MapController _mapController;

  final Map<String, IconData> _typeIcons = {
    'prefecture': Icons.account_balance,
    'municipality': Icons.location_city,
    'police': Icons.security,
    'gendarmerie': Icons.admin_panel_settings,
    'pompiers': Icons.local_fire_department,
    'court': Icons.gavel,
    'hospital': Icons.local_hospital,
    'clinic': Icons.medical_services,
    'veterinary': Icons.pets,
    'education': Icons.school,
    'sport': Icons.sports_soccer,
    'bank': Icons.monetization_on,
    'post': Icons.local_post_office,
    'bus_station': Icons.directions_bus,
    'parking': Icons.local_parking,
    'other': Icons.more_horiz,
  };

  final Map<String, Color> _typeColors = {
    'prefecture': const Color(0xFFC62828), // Deep Red
    'municipality': const Color(0xFF2E7D32), // Deep Green
    'police': const Color(0xFF1565C0), // Blue
    'gendarmerie': const Color(0xFF455A64), // Grey Blue
    'pompiers': const Color(0xFFD32F2F), // Red
    'court': const Color(0xFF5D4037), // Brown
    'hospital': const Color(0xFF1976D2), // Hospital Blue
    'clinic': const Color(0xFF0097A7), // Cyan
    'veterinary': const Color(0xFF689F38), // Light Green
    'education': const Color(0xFF7B1FA2), // Purple
    'sport': const Color(0xFFFBC02D), // Yellow
    'bank': const Color(0xFF388E3C), // Bank Green
    'post': const Color(0xFFFFA000), // Orange
    'bus_station': const Color(0xFF0288D1), // Sky Blue
    'parking': const Color(0xFF616161), // Grey
    'other': const Color(0xFF757575), // Light Grey
  };

  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return BlocBuilder<GovernmentServiceBloc, GovernmentServiceState>(
      builder: (context, state) {
        if (state is GovernmentServiceLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue));
        }

        List<GovernmentService> services = [];
        if (state is GovernmentServiceLoaded) {
          services = state.services;
        }

        return Stack(
          children: [
            _buildMap(services),
            if (_selectedService != null)
              _buildServiceDetails(_selectedService!, l),
          ],
        );
      },
    );
  }

  Widget _buildMap(List<GovernmentService> services) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(33.8300, -4.8300),
        initialZoom: 14,
        onPositionChanged: (position, hasGesture) {
          if (position.zoom != _currentZoom) {
            setState(() {
              _currentZoom = position.zoom!;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.sefrou_smart_city',
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayer(
          markers: services.map((service) {
            final isSelected = _selectedService?.id == service.id;
            final typeColor = _typeColors[service.type] ?? AppTheme.accentBlue;
            
            return Marker(
              point: LatLng(service.latitude, service.longitude),
              width: isSelected ? 100 : 80,
              height: isSelected ? 100 : 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentZoom > 15.5 || isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: typeColor.withOpacity(0.5), width: 0.5),
                      ),
                      child: Text(
                        service.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedService = service),
                    child: Container(
                      width: isSelected ? 40 : 30,
                      height: isSelected ? 40 : 30,
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: isSelected ? 2 : 1.5),
                        boxShadow: [
                          BoxShadow(color: typeColor.withOpacity(0.3), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                      child: Icon(
                        _typeIcons[service.type] ?? Icons.location_on, 
                        color: Colors.white, 
                        size: isSelected ? 22 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceDetails(GovernmentService service, String l) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (_typeColors[service.type] ?? AppTheme.accentBlue).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (_typeColors[service.type] ?? AppTheme.accentBlue).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _typeIcons[service.type] ?? Icons.location_on,
                    color: _typeColors[service.type] ?? AppTheme.accentBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.type.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: (_typeColors[service.type] ?? AppTheme.accentBlue),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedService = null),
                  icon: const Icon(Icons.close, color: Colors.white60),
                ),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.accentBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    service.address,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
            if (service.phone.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone, color: AppTheme.accentGreen, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    service.phone,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
