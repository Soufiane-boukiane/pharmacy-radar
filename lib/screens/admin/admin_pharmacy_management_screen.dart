import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../bloc/admin_pharmacy_bloc.dart';
import '../../bloc/pharmacy_bloc.dart';
import '../../bloc/map_bloc.dart';
import '../../services/firebase_service.dart';
import '../../widgets/admin/pharmacy_form_widget.dart';

class AdminPharmacyManagementScreen extends StatefulWidget {
  const AdminPharmacyManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminPharmacyManagementScreen> createState() =>
      _AdminPharmacyManagementScreenState();
}

class _AdminPharmacyManagementScreenState
    extends State<AdminPharmacyManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminPharmacyBloc>().add(const FetchAdminPharmacies());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminPharmacyBloc, AdminPharmacyState>(
      listener: (context, state) {
        if (state is AdminPharmacySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AdminPharmacyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AdminPharmacyBloc, AdminPharmacyState>(
        builder: (context, state) {
          if (state is AdminPharmacyLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentGreen,
              ),
            );
          } else if (state is AdminPharmacyLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pharmacy Management',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'إدارة الصيدليات',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAutoModeCard(context),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pharmacies List (${state.pharmacies.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showPharmacyDialog(context, null),
                        icon: const Icon(Icons.add_business_rounded),
                        label: const Text('Add Pharmacy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.pharmacies.isEmpty)
                    _buildEmptyState()
                  else
                    ...state.pharmacies.map((pharmacy) =>
                        _buildPharmacyCard(pharmacy, context)),
                ],
              ),
            );
          } else if (state is AdminPharmacyError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.local_pharmacy_rounded, size: 64, color: AppTheme.accentGreen.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No Pharmacies Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your 60 pharmacies here.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(dynamic pharmacy, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pharmacy.isDuty
              ? AppTheme.accentGreen.withOpacity(0.3)
              : pharmacy.isDayDuty
                  ? AppTheme.accentOrange.withOpacity(0.3)
                  : AppTheme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pharmacy.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (pharmacy.isDuty || pharmacy.isDayDuty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pharmacy.isDuty ? AppTheme.accentGreen.withOpacity(0.1) : AppTheme.accentOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: pharmacy.isDuty ? AppTheme.accentGreen.withOpacity(0.3) : AppTheme.accentOrange.withOpacity(0.3)),
                              ),
                              child: Text(
                                pharmacy.isDuty ? 'NIGHT DUTY' : 'DAY DUTY',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: pharmacy.isDuty ? AppTheme.accentGreen : AppTheme.accentOrange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pharmacy.address,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pharmacy.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showPharmacyDialog(context, pharmacy),
                      icon: const Icon(Icons.edit),
                      color: AppTheme.accentGreen,
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: AppTheme.cardBg,
                            title: Text('Delete Pharmacy', style: GoogleFonts.poppins(color: Colors.white)),
                            content: Text('Are you sure you want to delete "${pharmacy.name}"?', 
                              style: GoogleFonts.poppins(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  context.read<AdminPharmacyBloc>().add(DeleteAdminPharmacy(pharmacy.id));
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Deleting ${pharmacy.name}...'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      color: const Color(0xFFEF5350),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoModeCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: FirebaseService().getAppSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final settings = snapshot.data!;
        bool autoMode = settings['autoMode'] ?? false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.cardBg, AppTheme.darkBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatic Management',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'GMT+1 Morocco Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: autoMode,
                    onChanged: (value) async {
                      await FirebaseService().updateAppSettings({'autoMode': value});
                      setState(() {});
                      context.read<PharmacyBloc>().add(const FetchPharmacies());
                      context.read<MapBloc>().add(const RefreshMapPharmacies());
                    },
                    activeColor: AppTheme.accentGreen,
                  ),
                ],
              ),
              if (!autoMode) ...[
                const Divider(color: Colors.white10, height: 24),
                Row(
                  children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminPharmacyBloc>().add(const BulkUpdateDutyStatus(true));
                        context.read<PharmacyBloc>().add(const FetchPharmacies());
                        context.read<MapBloc>().add(const RefreshMapPharmacies());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                        foregroundColor: AppTheme.accentGreen,
                        side: BorderSide(color: AppTheme.accentGreen),
                      ),
                      icon: const Icon(Icons.toggle_on),
                      label: const Text('Activate All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminPharmacyBloc>().add(const BulkUpdateDutyStatus(false));
                        context.read<PharmacyBloc>().add(const FetchPharmacies());
                        context.read<MapBloc>().add(const RefreshMapPharmacies());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent),
                      ),
                      icon: const Icon(Icons.toggle_off),
                      label: const Text('Deactivate All'),
                    ),
                  ),
                ],
              ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSelector(BuildContext context, String label, String time, Function(String) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary),
        ),
        InkWell(
          onTap: () async {
            final timeOfDay = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(time.split(':')[0]),
                minute: int.parse(time.split(':')[1]),
              ),
            );
            if (timeOfDay != null) {
              final formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
              onUpdate(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPharmacyDialog(BuildContext context, dynamic pharmacy) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBg,
        child: PharmacyFormWidget(
          pharmacy: pharmacy,
          onSubmit: (pharmacyObj) {
            if (pharmacy == null) {
              context.read<AdminPharmacyBloc>().add(
                    AddAdminPharmacy(pharmacyObj),
                  );
            } else {
              context.read<AdminPharmacyBloc>().add(
                    UpdateAdminPharmacy(pharmacyObj),
                  );
            }
          },
        ),
      ),
    );
  }
}
