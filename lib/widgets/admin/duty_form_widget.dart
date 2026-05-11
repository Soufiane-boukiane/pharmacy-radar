import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../models/duty_schedule.dart';
import '../../models/pharmacy.dart';
import '../../bloc/language_bloc.dart';
import '../../services/translation_service.dart';

class DutyFormWidget extends StatefulWidget {
  final DutySchedule? dutySchedule;
  final List<Pharmacy> pharmacies;
  final Function(DutySchedule schedule) onSubmit;

  const DutyFormWidget({
    Key? key,
    this.dutySchedule,
    required this.pharmacies,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<DutyFormWidget> createState() => _DutyFormWidgetState();
}

class _DutyFormWidgetState extends State<DutyFormWidget> {
  late String selectedPharmacyId;
  late DateTime startDate;
  late DateTime endDate;
  late bool isActive;
  late bool isDayDuty;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    if (widget.dutySchedule != null) {
      selectedPharmacyId = widget.dutySchedule!.pharmacyId;
      startDate = widget.dutySchedule!.startDate;
      endDate = widget.dutySchedule!.endDate;
      isActive = widget.dutySchedule!.isActive;
      isDayDuty = widget.dutySchedule!.isDayDuty;
      notesController = TextEditingController(text: widget.dutySchedule!.notes);
    } else {
      selectedPharmacyId = widget.pharmacies.isNotEmpty ? widget.pharmacies.first.id : '';
      startDate = DateTime.now();
      endDate = DateTime.now().add(const Duration(days: 1));
      isActive = true;
      isDayDuty = false;
      notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? startDate : endDate),
      );
      if (time != null) {
        setState(() {
          final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) {
            startDate = newDateTime;
          } else {
            endDate = newDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dutySchedule == null 
                  ? Translations.getText('duty_management', l) + ' - ' + Translations.getText('add', l)
                  : Translations.getText('duty_management', l) + ' - ' + Translations.getText('edit', l),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel(Translations.getText('pharmacies', l).replaceAll('s', '')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPharmacyId,
              isExpanded: true, // Fix for overflow
              items: widget.pharmacies.map((pharmacy) {
                return DropdownMenuItem(
                  value: pharmacy.id,
                  child: Text(
                    pharmacy.name,
                    style: GoogleFonts.poppins(fontSize: 14),
                    overflow: TextOverflow.ellipsis, // Ensure text fits
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedPharmacyId = value);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardBgLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildDateTimePicker(l == 'fr' ? 'Début' : (l == 'ar' ? 'البدء' : 'Start'), startDate, () => _selectDateTime(context, true))),
                const SizedBox(width: 12),
                Expanded(child: _buildDateTimePicker(l == 'fr' ? 'Fin' : (l == 'ar' ? 'الانتهاء' : 'End'), endDate, () => _selectDateTime(context, false))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(l == 'fr' ? 'Statut Actif' : (l == 'ar' ? 'مفعل' : 'Active Status')),
                Switch.adaptive(
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  activeColor: AppTheme.accentGreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel(l == 'ar' ? 'حراسة نهارية (Garde Jour)' : 'Daytime Duty'),
                Switch.adaptive(
                  value: isDayDuty,
                  onChanged: (value) => setState(() => isDayDuty = value),
                  activeColor: AppTheme.accentOrange,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(Translations.getText('cancel', l), style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final pharmacyName = widget.pharmacies.firstWhere((p) => p.id == selectedPharmacyId).name;
                      final schedule = DutySchedule(
                        id: widget.dutySchedule?.id ?? '',
                        pharmacyId: selectedPharmacyId,
                        pharmacyName: pharmacyName,
                        startDate: startDate,
                        endDate: endDate,
                        isActive: isActive,
                        isDayDuty: isDayDuty,
                        notes: notesController.text,
                      );
                      widget.onSubmit(schedule);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(Translations.getText('save', l), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary));
  }

  Widget _buildDateTimePicker(String label, DateTime value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppTheme.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${value.day}/${value.month} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
