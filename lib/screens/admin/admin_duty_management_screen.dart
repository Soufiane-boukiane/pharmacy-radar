import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../bloc/admin_duty_bloc.dart';
import '../../bloc/pharmacy_bloc.dart';
import '../../bloc/language_bloc.dart';
import '../../services/translation_service.dart';
import '../../models/duty_schedule.dart';
import '../../widgets/admin/duty_form_widget.dart';
import '../../widgets/admin/admin_smart_scan_widget.dart';
import '../../models/pharmacy.dart';
import '../../widgets/admin/admin_quick_duty_selector.dart';
import '../../widgets/admin/admin_map_editor.dart';
import '../../widgets/admin/admin_government_map_editor.dart';

class AdminDutyManagementScreen extends StatefulWidget {
  const AdminDutyManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminDutyManagementScreen> createState() =>
      _AdminDutyManagementScreenState();
}

class _AdminDutyManagementScreenState extends State<AdminDutyManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDutyBloc>().add(const FetchAdminDutySchedules());
  }

  void _handleScanResult(Map<String, dynamic> result) {
    final pharmacies = context.read<PharmacyBloc>().state is PharmacyLoaded
        ? (context.read<PharmacyBloc>().state as PharmacyLoaded).pharmacies
        : <Pharmacy>[];

    final pharmacy = pharmacies.firstWhere(
      (p) => p.name.contains(result['pharmacyName']),
      orElse: () => pharmacies.first,
    );

    final newSchedule = DutySchedule(
      id: '',
      pharmacyId: pharmacy.id,
      pharmacyName: pharmacy.name,
      startDate: result['startDate'],
      endDate: result['endDate'],
      isActive: true,
    );

    _showDutyDialog(context, newSchedule);
  }

  void _handleSyncOSM(BuildContext context) {
    context.read<AdminDutyBloc>().add(const SyncOSMPharmacies());
    context.read<PharmacyBloc>().add(const FetchPharmacies());
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          title: Text(
            l == 'ar' ? 'إدارة المدينة' : (l == 'fr' ? 'Gestion de la Ville' : 'City Management'),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l == 'ar' ? 'الجداول' : 'Schedules'),
              Tab(text: l == 'ar' ? 'إعداد سريع' : 'Quick Setup'),
              Tab(text: l == 'ar' ? 'خريطة الصيدليات' : 'Pharmacy Map'),
              Tab(text: l == 'ar' ? 'خريطة المرافق' : 'Gov Map'),
            ],
            indicatorColor: AppTheme.accentGreen,
          ),
        ),
        body: TabBarView(
          children: [
            BlocListener<AdminDutyBloc, AdminDutyState>(
              listener: (context, state) {
                if (state is AdminDutySuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is AdminDutyError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: BlocBuilder<AdminDutyBloc, AdminDutyState>(
                builder: (context, state) {
                  if (state is AdminDutyLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGreen,
                      ),
                    );
                  } else if (state is AdminDutyLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminSmartScanWidget(
                            onScanComplete: _handleScanResult,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duty Schedules',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _handleSyncOSM(context),
                                    icon: const Icon(Icons.sync, color: AppTheme.accentGreen),
                                    label: Text(
                                      l == 'fr' ? 'Sync OSM' : (l == 'ar' ? 'مزامنة OSM' : 'Sync OSM'),
                                      style: const TextStyle(color: AppTheme.accentGreen),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showDutyDialog(context, null),
                                    icon: const Icon(Icons.add),
                                    label: Text(Translations.getText('add', l)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (state.schedules.isEmpty)
                            Center(
                              child: Text(
                                'No duty schedules',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          else ...[
                            if (state.schedules.any((s) => s.isDayDuty)) ...[
                              Text(
                                l == 'ar' ? 'حراسة نهارية' : 'Daytime Duty',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...state.schedules.where((s) => s.isDayDuty).map((schedule) =>
                                  _buildDutyCard(schedule, context)),
                              const SizedBox(height: 16),
                            ],
                            if (state.schedules.any((s) => !s.isDayDuty)) ...[
                              Text(
                                l == 'ar' ? 'حراسة ليلية' : 'Night Duty',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...state.schedules.where((s) => !s.isDayDuty).map((schedule) =>
                                  _buildDutyCard(schedule, context)),
                            ],
                          ],
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const AdminQuickDutySelector(),
            const AdminMapEditor(),
            const AdminGovernmentMapEditor(),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyCard(DutySchedule schedule, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Text(
                        schedule.pharmacyName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${schedule.startDate.toString().split('.')[0]} - ${schedule.endDate.toString().split('.')[0]}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.isActive
                        ? (schedule.isDayDuty ? AppTheme.accentOrange.withValues(alpha: 0.2) : AppTheme.accentGreen.withValues(alpha: 0.2))
                        : AppTheme.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: schedule.isActive
                          ? (schedule.isDayDuty ? AppTheme.accentOrange : AppTheme.accentGreen)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showDutyDialog(context, schedule),
                  icon: const Icon(Icons.edit),
                  color: AppTheme.accentGreen,
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    context
                        .read<AdminDutyBloc>()
                        .add(DeleteAdminDutySchedule(schedule.id));
                  },
                  icon: const Icon(Icons.delete),
                  color: Color(0xFFEF5350),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDutyDialog(BuildContext context, DutySchedule? schedule) {
    final pharmacies = context.read<PharmacyBloc>().state is PharmacyLoaded
        ? (context.read<PharmacyBloc>().state as PharmacyLoaded).pharmacies
        : <Pharmacy>[];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBg,
        child: DutyFormWidget(
          dutySchedule: schedule,
          pharmacies: pharmacies,
          onSubmit: (dutySchedule) {
            if (schedule == null) {
              context.read<AdminDutyBloc>().add(
                    AddAdminDutySchedule(dutySchedule),
                  );
            } else {
              context.read<AdminDutyBloc>().add(
                    UpdateAdminDutySchedule(dutySchedule),
                  );
            }
          },
        ),
      ),
    );
  }
}
