import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../models/pharmacy.dart';
import '../../bloc/pharmacy_bloc.dart';
import '../../services/pharmacy_service.dart';
import '../../bloc/admin_duty_bloc.dart';
import '../../models/duty_schedule.dart';

class AdminQuickDutySelector extends StatefulWidget {
  const AdminQuickDutySelector({Key? key}) : super(key: key);

  @override
  State<AdminQuickDutySelector> createState() => _AdminQuickDutySelectorState();
}

class _AdminQuickDutySelectorState extends State<AdminQuickDutySelector> {
  final Set<String> _selectedIds = {};
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacyBloc, PharmacyState>(
      builder: (context, state) {
        if (state is PharmacyLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is PharmacyLoaded) {
          final pharmacies = state.pharmacies;
          return Column(
            children: [
              _buildDateTimeSelectors(context),
              const Divider(color: AppTheme.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.accentBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select pharmacies for night duty. Others will be regular.',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = pharmacies[index];
                    final isSelected = _selectedIds.contains(pharmacy.id);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppTheme.accentGreen : AppTheme.cardBgLight,
                        child: Icon(
                          Icons.local_pharmacy,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                      title: Text(
                        pharmacy.name,
                        style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                      ),
                      subtitle: Text(
                        pharmacy.address,
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: AppTheme.accentGreen,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(pharmacy.id);
                            } else {
                              _selectedIds.remove(pharmacy.id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(pharmacy.id);
                          } else {
                            _selectedIds.add(pharmacy.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              _buildSaveButton(context, pharmacies),
            ],
          );
        }
        
        return const Center(child: Text('Failed to load pharmacies'));
      },
    );
  }

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPickerBox(
                  label: 'Start Date & Time',
                  value: '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startTime.format(context)}',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() {
                          _startDate = date;
                          _startTime = time;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPickerBox(
                  label: 'End Date & Time',
                  value: '${_endDate.day}/${_endDate.month}/${_endDate.year} ${_endTime.format(context)}',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() {
                          _endDate = date;
                          _endTime = time;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerBox({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.accentGreen),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.edit, size: 12, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, List<Pharmacy> pharmacies) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedIds.isEmpty ? null : () => _saveSchedules(context, pharmacies),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppTheme.accentGreen,
        ),
        child: Text(
          'Deploy Night Duty (${_selectedIds.length})',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveSchedules(BuildContext context, List<Pharmacy> pharmacies) {
    final startDateTime = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    final endDateTime = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    for (final id in _selectedIds) {
      final pharmacy = pharmacies.firstWhere((p) => p.id == id);
      final schedule = DutySchedule(
        id: '',
        pharmacyId: pharmacy.id,
        pharmacyName: pharmacy.name,
        startDate: startDateTime,
        endDate: endDateTime,
        isActive: true,
        notes: 'Quick Setup Duty',
      );
      context.read<AdminDutyBloc>().add(AddAdminDutySchedule(schedule));
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Schedules deployed for ${_selectedIds.length} pharmacies'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
    
    setState(() => _selectedIds.clear());
  }
}
