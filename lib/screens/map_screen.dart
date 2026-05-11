import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../bloc/map_bloc.dart';
import '../bloc/language_bloc.dart';
import '../models/pharmacy.dart';
import '../models/government_service.dart';
import '../bloc/pharmacy_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_3d_simulation_screen.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as mgl;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Pharmacy? _selectedPharmacy;
  GovernmentService? _selectedService;
  late MapController _mapController;
  double _currentZoom = 14.0;
  bool _isWalkingMode = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Trigger map initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().add(const InitializeMap());
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentGreen,
            ),
          );
        } else if (state is MapLoaded) {
          return Stack(
            children: [
              _buildMap(state, l),
              _buildTopControls(state),
              _buildTransportToggle(),
              if (state.routePoints.isNotEmpty)
                _buildRouteInfo(state),
              if (_selectedPharmacy != null)
                _buildPharmacyBottomSheet(_selectedPharmacy!, l),
              if (_selectedService != null)
                _buildServiceBottomSheet(_selectedService!, l),
            ],
          );
        } else if (state is MapError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(state.message, style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<MapBloc>().add(const InitializeMap()),
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

  Widget _buildMap(MapLoaded state, String l) {
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
        if (state.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.routePoints,
                strokeWidth: (_currentZoom - 11).clamp(2.0, 8.0),
                color: Colors.cyanAccent,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (state.userLocation != null)
              Marker(
                point: state.userLocation!,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
              ),
            // Pharmacy Markers
            ...state.pharmacies.map((pharmacy) {
              final isSelected = _selectedPharmacy?.id == pharmacy.id;
              final markerColor = pharmacy.isDuty ? AppTheme.accentGreen : (pharmacy.isDayDuty ? AppTheme.accentOrange : Colors.redAccent);
              final glowColor = pharmacy.isDuty ? AppTheme.accentGreen : (pharmacy.isDayDuty ? AppTheme.accentOrange : Colors.red.withOpacity(0.4));
              
              return Marker(
                point: LatLng(pharmacy.latitude, pharmacy.longitude),
                width: 120,
                height: 120,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      Positioned(
                        bottom: isSelected ? 30 : 25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: markerColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            pharmacy.name.replaceAll(RegExp(r'صيدلية|Pharmacy', caseSensitive: false), '').trim(),
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedPharmacy = pharmacy;
                        _selectedService = null;
                      }),
                      child: _DutyMarker(
                        isDuty: pharmacy.isDuty,
                        isDayDuty: pharmacy.isDayDuty,
                        isSelected: isSelected,
                        markerColor: markerColor,
                        glowColor: glowColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Service Markers
            ...state.governmentServices.map((service) {
              final isSelected = _selectedService?.id == service.id;
              final markerColor = AppTheme.accentBlue;
              
              return Marker(
                point: LatLng(service.latitude, service.longitude),
                width: 120,
                height: 120,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      Positioned(
                        bottom: isSelected ? 30 : 25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: markerColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            service.name,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedService = service;
                        _selectedPharmacy = null;
                      }),
                      child: _ServiceMarker(
                        type: service.type,
                        isSelected: isSelected,
                        markerColor: markerColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTopControls(MapLoaded state) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search pharmacies...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppTheme.accentGreen),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: () {
              if (state.userLocation != null) {
                _mapController.move(state.userLocation!, 15);
              }
            },
            backgroundColor: AppTheme.accentGreen,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: 'btn3d',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map3DSimulationScreen(
                  initialWalkingMode: _isWalkingMode,
                  routePoints: state.routePoints.map((p) => mgl.LatLng(p.latitude, p.longitude)).toList(),
                  selectedPharmacy: _selectedPharmacy,
                ),
              ),
            ),
            backgroundColor: AppTheme.accentGreen,
            child: const Icon(Icons.view_in_ar_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportToggle() {
    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
        ),
        child: Column(
          children: [
            _buildToggleIcon(Icons.directions_walk, _isWalkingMode, () {
              setState(() => _isWalkingMode = true);
            }),
            const SizedBox(height: 4),
            _buildToggleIcon(Icons.directions_car, !_isWalkingMode, () {
              setState(() => _isWalkingMode = false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 20),
      ),
    );
  }

  Widget _buildRouteInfo(MapLoaded state) {
    return const SizedBox.shrink();
  }

  Widget _buildPharmacyBottomSheet(Pharmacy pharmacy, String l) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
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
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pharmacy.address,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedPharmacy = null),
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(GetDirections(LatLng(pharmacy.latitude, pharmacy.longitude)));
                      setState(() => _selectedPharmacy = null);
                    },
                    icon: const Icon(Icons.route),
                    label: const Text('Itinerary / تتبع المسار'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _makeCall(pharmacy.phone),
                  icon: const Icon(Icons.phone),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.cardBg,
                    foregroundColor: AppTheme.accentGreen,
                    side: const BorderSide(color: AppTheme.accentGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchNavigation(Pharmacy pharmacy) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildServiceBottomSheet(GovernmentService service, String l) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
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
          children: [
            Row(
              children: [
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
                        service.address,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedService = null),
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(GetDirections(LatLng(service.latitude, service.longitude)));
                      // After getting directions, we should navigate to simulation
                      // But for consistency we'll let the user click simulation or show it automatically
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Map3DSimulationScreen(
                            selectedService: service,
                            // We don't have the route yet in state, so simulation will show it when it updates
                          ),
                        ),
                      );
                      setState(() => _selectedService = null);
                    },
                    icon: const Icon(Icons.threed_rotation),
                    label: const Text('3D Simulation / محاكاة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (service.phone.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _makeCall(service.phone),
                    icon: const Icon(Icons.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.cardBg,
                      foregroundColor: AppTheme.accentBlue,
                      side: const BorderSide(color: AppTheme.accentBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class _DutyMarker extends StatelessWidget {
  final bool isDuty;
  final bool isDayDuty;
  final bool isSelected;
  final Color markerColor;
  final Color glowColor;

  const _DutyMarker({
    required this.isDuty,
    this.isDayDuty = false,
    required this.isSelected,
    required this.markerColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasDuty = isDuty || isDayDuty;
    return Container(
      decoration: BoxDecoration(
        color: hasDuty ? markerColor : AppTheme.cardBg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: isSelected ? 8 : 4,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSelected ? 4.0 : 3.0),
        child: Icon(
          Icons.local_pharmacy,
          color: hasDuty ? Colors.white : markerColor,
          size: isSelected ? 24 : 14,
        ),
      ),
    );
  }
}

class _ServiceMarker extends StatelessWidget {
  final String type;
  final bool isSelected;
  final Color markerColor;

  const _ServiceMarker({
    required this.type,
    required this.isSelected,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case 'police': icon = Icons.security; break;
      case 'hospital': icon = Icons.local_hospital; break;
      case 'pompiers': icon = Icons.local_fire_department; break;
      case 'prefecture': icon = Icons.account_balance; break;
      case 'municipality': icon = Icons.location_city; break;
      case 'education': icon = Icons.school; break;
      default: icon = Icons.business;
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: markerColor.withOpacity(0.4),
            blurRadius: isSelected ? 8 : 4,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSelected ? 4.0 : 3.0),
        child: Icon(
          icon,
          color: Colors.white,
          size: isSelected ? 24 : 14,
        ),
      ),
    );
  }
}
