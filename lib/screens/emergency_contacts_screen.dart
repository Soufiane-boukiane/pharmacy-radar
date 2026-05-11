import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/government_service.dart';
import '../bloc/map_bloc.dart';
import 'map_3d_simulation_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as mgl;
class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          l == 'ar' ? 'أرقام الطوارئ والمرافق' : 'Urgences & Services',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
        elevation: 0,
      ),
      body: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLoaded && state.routePoints.isNotEmpty) {
            // This is a bit tricky since we might be triggering this from the list
            // We'll handle navigation inside the button's onPressed for better control
          }
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('government_services').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  l == 'ar' ? 'لا توجد مرافق متاحة حالياً' : 'No facilities available currently',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              );
            }

            final contacts = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contactData = contacts[index].data() as Map<String, dynamic>;
                final service = GovernmentService.fromJson(contactData);
                final name = service.name;
                final number = service.phone.isNotEmpty ? service.phone : service.address;
                final type = service.type;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(type), color: Colors.redAccent),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      number,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Simulation / Navigation Button
                        ElevatedButton(
                          onPressed: () async {
                            final mapBloc = context.read<MapBloc>();
                            final mapState = mapBloc.state;
                            
                            if (mapState is MapLoaded) {
                              if (mapState.userLocation == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l == 'ar' ? 'يرجى تفعيل الموقع' : 'Please enable location'))
                                );
                                return;
                              }

                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator()),
                              );

                              try {
                                // Get directions first
                                mapBloc.add(GetDirections(LatLng(service.latitude, service.longitude)));
                                
                                // Wait for route points to be updated in state
                                // For simplicity in this demo, we'll just wait a bit or use the routing service directly
                                // A better way is to listen to the state change, but here we'll use direct navigation
                                
                                final route = await mapBloc.state is MapLoaded 
                                  ? (mapBloc.state as MapLoaded).routePoints 
                                  : <LatLng>[];

                                if (context.mounted) {
                                  Navigator.pop(context); // Remove loading
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Map3DSimulationScreen(
                                        selectedService: service,
                                        routePoints: route.map((p) => mgl.LatLng(p.latitude, p.longitude)).toList(),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue.withOpacity(0.2),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            minimumSize: Size.zero,
                          ),
                          child: const Icon(Icons.threed_rotation, color: AppTheme.accentBlue, size: 20),
                        ),
                        const SizedBox(width: 8),
                        if (service.phone.isNotEmpty)
                          ElevatedButton(
                            onPressed: () => _makeCall(service.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              minimumSize: Size.zero,
                            ),
                            child: const Icon(Icons.phone, color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'police': return Icons.security;
      case 'hospital': return Icons.local_hospital;
      case 'pompiers': return Icons.local_fire_department;
      case 'prefecture': return Icons.account_balance;
      case 'municipality': return Icons.location_city;
      case 'education': return Icons.school;
      case 'clinic': return Icons.medical_services;
      default: return Icons.location_on;
    }
  }
}

class RoundedRectangleAppStyle {
  static const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const circleShape = CircleBorder();
}
