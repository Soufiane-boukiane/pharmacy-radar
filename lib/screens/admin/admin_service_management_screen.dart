import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../models/government_service.dart';
import '../../bloc/government_service_bloc.dart';

class AdminServiceManagementScreen extends StatefulWidget {
  const AdminServiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminServiceManagementScreen> createState() => _AdminServiceManagementScreenState();
}

class _AdminServiceManagementScreenState extends State<AdminServiceManagementScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'police';

  final Map<String, IconData> _typeIcons = {
    'police': Icons.security,
    'hospital': Icons.local_hospital,
    'pompiers': Icons.local_fire_department,
    'prefecture': Icons.account_balance,
    'municipality': Icons.location_city,
    'education': Icons.school,
    'other': Icons.more_horiz,
  };

  void _addService() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: Text('Add Public Facility', style: GoogleFonts.poppins(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Facility Name'),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_addressController, 'Address'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: AppTheme.cardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _typeIcons.keys.map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_typeIcons[type], color: AppTheme.accentBlue),
                        const SizedBox(width: 10),
                        Text(type.toUpperCase()),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => _selectedType = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final id = 'gs_${DateTime.now().millisecondsSinceEpoch}';
                  final service = GovernmentService(
                    id: id,
                    name: _nameController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    type: _selectedType,
                    latitude: 33.8300,
                    longitude: -4.8300,
                  );
                  context.read<GovernmentServiceBloc>().add(AddGovernmentService(service));
                  _nameController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add Facility'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.accentBlue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      floatingActionButton: FloatingActionButton(
        onPressed: _addService,
        backgroundColor: AppTheme.accentBlue,
        child: const Icon(Icons.add_location_alt),
      ),
      body: BlocBuilder<GovernmentServiceBloc, GovernmentServiceState>(
        builder: (context, state) {
          if (state is GovernmentServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GovernmentServiceLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return Center(child: Text('No facilities found', style: GoogleFonts.poppins(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.1),
                        child: Icon(_typeIcons[s.type] ?? Icons.location_on, color: AppTheme.accentBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(s.phone.isNotEmpty ? s.phone : s.address, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: AppTheme.cardBg,
                              title: Text('Delete Facility', style: GoogleFonts.poppins(color: Colors.white)),
                              content: Text('Are you sure you want to delete "${s.name}"?', style: GoogleFonts.poppins(color: Colors.white70)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    context.read<GovernmentServiceBloc>().add(DeleteGovernmentService(s.id));
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
