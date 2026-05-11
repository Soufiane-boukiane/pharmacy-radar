import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map_bloc.dart';
import '../models/pharmacy.dart';
import '../theme/app_theme.dart';
import '../models/government_service.dart';

class Map3DSimulationScreen extends StatefulWidget {
  final bool initialWalkingMode;
  final List<LatLng> routePoints;
  final Pharmacy? selectedPharmacy;
  final GovernmentService? selectedService;
  const Map3DSimulationScreen({
    Key? key, 
    this.initialWalkingMode = true,
    this.routePoints = const [],
    this.selectedPharmacy,
    this.selectedService,
  }) : super(key: key);

  @override
  State<Map3DSimulationScreen> createState() => _Map3DSimulationScreenState();
}

class _Map3DSimulationScreenState extends State<Map3DSimulationScreen> {
  MapLibreMapController? mapController;
  late bool _isWalkingMode;

  @override
  void initState() {
    super.initState();
    _isWalkingMode = widget.initialWalkingMode;
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _initUserLocationAndFly();
  }

  void _drawRouteLine() {
    if (widget.routePoints.isNotEmpty && mapController != null) {
      mapController!.addLine(
        LineOptions(
          geometry: widget.routePoints,
          lineColor: "#00E5FF", // Bright Cyan
          lineWidth: 8.0,
          lineOpacity: 1.0,
          lineJoin: "round",
        ),
      );
    }
  }

  void _initUserLocationAndFly() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
            tilt: 60.0,
            bearing: 0,
          ),
        ),
        duration: const Duration(seconds: 3),
      );
      _startSimulationTour();
    } catch (e) {
      _startSimulationTour();
    }
  }

  void _addMarkers() {
    _addPharmacyMarkers();
    _addServiceMarkers();
  }

  final Map<String, String> _typeColors = {
    'police': '#1565C0', // Blue
    'hospital': '#1976D2', // Blue
    'pompiers': '#D32F2F', // Red
    'prefecture': '#C62828', // Red
    'municipality': '#2E7D32', // Green
    'education': '#7B1FA2', // Purple
    'other': '#757575', // Gray
  };

  void _addServiceMarkers() {
    final mapState = context.read<MapBloc>().state;
    if (mapState is MapLoaded && mapController != null) {
      for (var service in mapState.governmentServices) {
        final bool isSelected = widget.selectedService?.id == service.id;
        final String color = isSelected ? '#FFEB3B' : (_typeColors[service.type] ?? '#00B0FF');

        mapController!.addCircle(
          CircleOptions(
            geometry: LatLng(service.latitude, service.longitude),
            circleColor: color,
            circleRadius: isSelected ? 12.0 : 8.0,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2.0,
          ),
        );

        mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(service.latitude, service.longitude),
            textField: service.name,
            textSize: isSelected ? 12.0 : 9.0,
            textOffset: const Offset(0, 2.5),
            textColor: '#FFFFFF',
            textHaloColor: '#000000',
            textHaloWidth: 1.5,
          ),
        );
      }
    }
  }

  void _addPharmacyMarkers() {
    final mapState = context.read<MapBloc>().state;
    if (mapState is MapLoaded && mapController != null) {
      for (var pharmacy in mapState.pharmacies) {
        final bool isSelected = widget.selectedPharmacy?.id == pharmacy.id;
        String markerColor = '#F44336';
        if (isSelected) {
          markerColor = '#00B0FF';
        } else if (pharmacy.isDayDuty) {
          markerColor = '#FF9800'; // Orange for Day Duty
        } else if (pharmacy.isDuty) {
          markerColor = '#4CAF50'; // Green for Night Duty
        }

        mapController!.addCircle(
          CircleOptions(
            geometry: LatLng(pharmacy.latitude, pharmacy.longitude),
            circleColor: markerColor,
            circleRadius: isSelected ? 10.0 : 7.0,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: isSelected ? 3.0 : 1.5,
          ),
        );
        
        mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(pharmacy.latitude, pharmacy.longitude),
            textField: pharmacy.name.replaceAll(RegExp(r'صيدلية|Pharmacy', caseSensitive: false), '').trim(),
            textSize: isSelected ? 13.0 : 10.0,
            textOffset: const Offset(0, 2.5),
            textColor: '#FFFFFF',
            textHaloColor: '#000000',
            textHaloWidth: 1.5,
          ),
        );
      }
    }
  }

  void _startSimulationTour() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(33.8298, -4.8277),
          zoom: 16.5,
          tilt: 55.0,
          bearing: 90.0,
        ),
      ),
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          '3D Simulation / محاكاة ثلاثية الأبعاد',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
      ),
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: () {
              _addMarkers();
              _drawRouteLine();
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.8300, -4.8277),
              zoom: 17.0,
              tilt: 60.0,
              bearing: 45.0,
            ),
            styleString: """{
              "version": 8,
              "sources": {
                "arcgis-satellite": {
                  "type": "raster",
                  "tiles": [
                    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  ],
                  "tileSize": 256
                }
              },
              "layers": [
                {
                  "id": "satellite",
                  "type": "raster",
                  "source": "arcgis-satellite",
                  "minzoom": 0,
                  "maxzoom": 22
                }
              ]
            }""",
            trackCameraPosition: true,
            myLocationEnabled: true,
          ),
          _buildSimulationControls(),
          _buildTransportModeToggle(),
          if (widget.selectedPharmacy != null || widget.selectedService != null)
            _buildInfoOverlayBanner(),
          _buildInfoOverlay(),
        ],
      ),
    );
  }

  Widget _buildInfoOverlayBanner() {
    final name = widget.selectedPharmacy?.name ?? widget.selectedService?.name ?? '';
    final address = widget.selectedPharmacy?.address ?? widget.selectedService?.address ?? '';
    final isPharmacy = widget.selectedPharmacy != null;
    
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPharmacy ? AppTheme.accentGreen.withOpacity(0.5) : AppTheme.accentBlue.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isPharmacy ? AppTheme.accentGreen : AppTheme.accentBlue, shape: BoxShape.circle),
              child: Icon(isPharmacy ? Icons.local_pharmacy : Icons.business, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    address,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportModeToggle() {
    return Positioned(
      bottom: 120,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
        ),
        child: Row(
          children: [
            _buildModeIcon(Icons.directions_walk, _isWalkingMode, () {
              setState(() => _isWalkingMode = true);
              _updateSimulationView();
            }),
            const SizedBox(width: 8),
            _buildModeIcon(Icons.directions_car, !_isWalkingMode, () {
              setState(() => _isWalkingMode = false);
              _updateSimulationView();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModeIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 24),
      ),
    );
  }

  void _updateSimulationView() async {
    if (mapController == null) return;
    
    final zoom = _isWalkingMode ? 18.5 : 16.5;
    final tilt = _isWalkingMode ? 75.0 : 50.0;
    
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: mapController!.cameraPosition!.target,
          zoom: zoom,
          tilt: tilt,
          bearing: mapController!.cameraPosition!.bearing,
        ),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildSimulationControls() {
    return Positioned(
      bottom: 120,
      right: 20,
      child: Column(
        children: [
          _buildControlButton(Icons.add, () => mapController?.animateCamera(CameraUpdate.zoomIn())),
          const SizedBox(height: 10),
          _buildControlButton(Icons.remove, () => mapController?.animateCamera(CameraUpdate.zoomOut())),
          const SizedBox(height: 10),
          _buildControlButton(Icons.view_in_ar_rounded, () {
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(33.8300, -4.8300),
                zoom: 16,
                tilt: 70,
                bearing: 90,
              ),
            ));
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return FloatingActionButton(
      heroTag: null,
      mini: true,
      backgroundColor: AppTheme.accentGreen,
      onPressed: onTap,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
        ),
        child: Row(
          children: [
            const Icon(Icons.navigation_rounded, color: AppTheme.accentGreen, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode Simulation Réaliste',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Exploration 3D de la ville de Sefrou',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
