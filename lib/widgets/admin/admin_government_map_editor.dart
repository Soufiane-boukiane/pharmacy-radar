import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../models/government_service.dart';
import '../../bloc/government_service_bloc.dart';

class AdminGovernmentMapEditor extends StatefulWidget {
  const AdminGovernmentMapEditor({Key? key}) : super(key: key);

  @override
  State<AdminGovernmentMapEditor> createState() => _AdminGovernmentMapEditorState();
}

class _AdminGovernmentMapEditorState extends State<AdminGovernmentMapEditor> {
  LatLng? _pickedLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedType = 'prefecture';
  bool _isFetchingInfo = false;
  late MapController _mapController;
  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

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
    'bus_station': Icons.directions_bus,
    'parking': Icons.local_parking,
    'other': Icons.more_horiz,
  };

  final Map<String, Color> _typeColors = {
    'prefecture': const Color(0xFFC62828),
    'municipality': const Color(0xFF2E7D32),
    'police': const Color(0xFF1565C0),
    'gendarmerie': const Color(0xFF455A64),
    'pompiers': const Color(0xFFD32F2F),
    'court': const Color(0xFF5D4037),
    'hospital': const Color(0xFF1976D2),
    'clinic': const Color(0xFF0097A7),
    'veterinary': const Color(0xFF689F38),
    'education': const Color(0xFF7B1FA2),
    'sport': const Color(0xFFFBC02D),
    'bank': const Color(0xFF388E3C),
    'post': const Color(0xFFFFA000),
    'bus_station': const Color(0xFF0288D1),
    'parking': const Color(0xFF616161),
    'other': const Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<GovernmentServiceBloc, GovernmentServiceState>(
      listener: (context, state) {
        if (state is GovernmentServiceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.accentBlue),
          );
        } else if (state is GovernmentServiceError) {
          String msg = state.message;
          if (msg.contains('permission-denied')) {
            msg = 'Permission Denied: Please update Firestore Security Rules to allow "government_services" collection.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(label: 'Dismiss', textColor: Colors.white, onPressed: () {}),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: BlocBuilder<GovernmentServiceBloc, GovernmentServiceState>(
          builder: (context, state) {
            List<GovernmentService> existingServices = [];
            if (state is GovernmentServiceLoaded) {
              existingServices = state.services;
            }

            return Stack(
              children: [
                FlutterMap(
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
                    onTap: (tapPosition, point) => _onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName: 'com.example.sefrou_smart_city',
                    ),
                    MarkerLayer(
                      markers: existingServices.map((s) {
                        final typeColor = _typeColors[s.type] ?? AppTheme.accentBlue;
                        return Marker(
                          point: LatLng(s.latitude, s.longitude),
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_currentZoom > 15.5)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBg.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: typeColor.withValues(alpha: 0.5), width: 0.5),
                                  ),
                                  child: Text(
                                    s.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: typeColor.withValues(alpha: 0.3), blurRadius: 8),
                                  ],
                                ),
                                child: Icon(_typeIcons[s.type] ?? Icons.location_on, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (_pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.add_location, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_isFetchingInfo)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue)),
                  ),
                _buildTopBanner(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkBg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, color: AppTheme.accentBlue, size: 18),
            const SizedBox(width: 10),
            Text(
              'Tap map to add Public Facility',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _pickedLocation = point;
      _isFetchingInfo = true;
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
    });

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'SefrouSmartCity/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _nameController.text = data['name'] ?? '';
        _addressController.text = data['display_name'] ?? '';
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isFetchingInfo = false);
      _showAddServiceDialog(point);
    }
  }

  void _showAddServiceDialog(LatLng point) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Public Facility', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildTypeSelector(setDialogState),
                  const SizedBox(height: 16),
                  _buildField('Facility Name', _nameController, Icons.business),
                  const SizedBox(height: 16),
                  _buildField('Phone', _phoneController, Icons.phone),
                  const SizedBox(height: 16),
                  _buildField('Address', _addressController, Icons.location_on),
                  const SizedBox(height: 32),
                  _buildActions(point),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(Function setDialogState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          dropdownColor: AppTheme.cardBg,
          items: _typeIcons.keys.map((type) => DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(_typeIcons[type], color: AppTheme.accentBlue, size: 20),
                const SizedBox(width: 12),
                Text(type.toUpperCase(), style: const TextStyle(color: Colors.white)),
              ],
            ),
          )).toList(),
          onChanged: (val) {
            if (val != null) setDialogState(() => _selectedType = val);
          },
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppTheme.accentBlue, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActions(LatLng point) {
    return Row(
      children: [
        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveService(point),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _saveService(LatLng point) async {
    if (_nameController.text.isEmpty) return;

    final service = GovernmentService(
      id: 'gs_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      latitude: point.latitude,
      longitude: point.longitude,
      type: _selectedType,
    );

    context.read<GovernmentServiceBloc>().add(AddGovernmentService(service));
    Navigator.pop(context);
  }
}
