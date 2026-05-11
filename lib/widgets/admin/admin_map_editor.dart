import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sefrou_smart_city/theme/app_theme.dart';
import 'package:sefrou_smart_city/models/pharmacy.dart';
import 'package:sefrou_smart_city/services/firebase_service.dart';
import 'package:sefrou_smart_city/bloc/pharmacy_bloc.dart';

class AdminMapEditor extends StatefulWidget {
  const AdminMapEditor({Key? key}) : super(key: key);

  @override
  State<AdminMapEditor> createState() => _AdminMapEditorState();
}

class _AdminMapEditorState extends State<AdminMapEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isFetchingInfo = false;
  late MapController _mapController;
  List<Map<String, dynamic>> _osmPharmacies = [];
  bool _isLoadingOSM = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchOSMPharmacies();
  }

  Future<void> _fetchOSMPharmacies() async {
    if (mounted) setState(() => _isLoadingOSM = true);
    try {
      // Deep Bounding Box Search for Sefrou (33.81 to 33.85, -4.85 to -4.81)
      const query = '[out:json][timeout:25];(node["amenity"~"pharmacy"](33.81,-4.85,33.85,-4.81);way["amenity"~"pharmacy"](33.81,-4.85,33.85,-4.81);relation["amenity"~"pharmacy"](33.81,-4.85,33.85,-4.81););out center;';
      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _osmPharmacies = List<Map<String, dynamic>>.from(data['elements']);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${_osmPharmacies.length} pharmacies in Sefrou from OSM'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('OSM Fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingOSM = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: BlocBuilder<PharmacyBloc, PharmacyState>(
        builder: (context, state) {
          List<Pharmacy> existingPharmacies = [];
          if (state is PharmacyLoaded) {
            existingPharmacies = state.pharmacies;
          }

          final allMarkers = _osmPharmacies.map((node) {
            final lat = (node['lat'] ?? node['center']?['lat']) as double;
            final lon = (node['lon'] ?? node['center']?['lon']) as double;
            final isNew = !existingPharmacies.any((p) => 
              (p.latitude - lat).abs() < 0.0001 && 
              (p.longitude - lon).abs() < 0.0001);
            
            final point = LatLng(lat, lon);
            final tags = node['tags'] as Map<String, dynamic>?;
            final name = tags?['name'] ?? tags?['name:ar'] ?? tags?['name:fr'] ?? 'Pharmacy';

            return Marker(
              point: point,
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () {
                  _nameController.text = name;
                  _addressController.text = tags?['addr:full'] ?? tags?['addr:street'] ?? 'Sefrou';
                  _showAddPharmacyDialog(point);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isNew ? Colors.red.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      Icons.local_pharmacy, 
                      color: isNew ? Colors.redAccent : Colors.blue.withValues(alpha: 0.5), 
                      size: isNew ? 32 : 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(33.8300, -4.8300),
                  initialZoom: 14,
                  onTap: (tapPosition, point) => _onMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: allMarkers),
                  MarkerLayer(
                    markers: existingPharmacies.map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 40,
                      height: 40,
                      child: Icon(Icons.local_pharmacy, color: AppTheme.accentGreen, size: 28),
                    )).toList(),
                  ),
                ],
              ),
              if (_isLoadingOSM || _isFetchingInfo)
                const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen)),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _fetchOSMPharmacies,
                        icon: const Icon(Icons.radar),
                        label: Text(_isLoadingOSM ? 'Scanning...' : 'Fetch Sefrou Pharmacies'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Total Discovery: ${_osmPharmacies.length}',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
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
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingInfo = false);
        _showAddPharmacyDialog(point);
      }
    }
  }

  void _showAddPharmacyDialog(LatLng point) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Discovery',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify and save to Sefrou SOS database',
                  style: GoogleFonts.poppins(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _buildField('Pharmacy Name', _nameController, Icons.business),
                const SizedBox(height: 16),
                _buildField('Phone Number', _phoneController, Icons.phone),
                const SizedBox(height: 16),
                _buildField('Full Address', _addressController, Icons.location_on),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _savePharmacy(point),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Save Pharmacy', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: Colors.white),
          maxLines: label.contains('Address') ? 3 : 1,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.accentGreen, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _savePharmacy(LatLng point) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    try {
      final pharmacy = Pharmacy(
        id: 'ph_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        latitude: point.latitude,
        longitude: point.longitude,
        isOpen: true,
        isDuty: false,
      );

      await FirebaseService().setData('pharmacies', pharmacy.id, pharmacy.toJson());
      
      if (mounted) {
        context.read<PharmacyBloc>().add(const FetchPharmacies());
        Navigator.pop(context);
        _fetchOSMPharmacies(); // Refresh radar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pharmacy "${pharmacy.name}" added!'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }
}
