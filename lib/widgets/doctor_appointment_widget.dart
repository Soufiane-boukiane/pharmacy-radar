import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_appointment.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentWidget extends StatefulWidget {
  const DoctorAppointmentWidget({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentWidget> createState() => _DoctorAppointmentWidgetState();
}

class _DoctorAppointmentWidgetState extends State<DoctorAppointmentWidget>
    with SingleTickerProviderStateMixin {
  final List<DoctorAppointment> _appointments = [
    const DoctorAppointment(
      id: '1',
      doctorName: 'Dr. Alaoui',
      specialty: 'Cardiologue',
      date: '15 Mai 2026',
      time: '10:30',
    ),
  ];

  late AnimationController _controller;

  static const Map<String, IconData> _specialtyIcons = {
    'cardiologue': Icons.favorite_rounded,
    'généraliste': Icons.medical_services_rounded,
    'dentiste': Icons.medical_services_rounded,
    'ophtalmologue': Icons.visibility_rounded,
    'dermatologue': Icons.face_rounded,
    'pédiatre': Icons.child_care_rounded,
    'gynécologue': Icons.pregnant_woman_rounded,
    'neurologue': Icons.psychology_rounded,
    'psychiatre': Icons.psychology_outlined,
  };

  static const Map<String, Color> _specialtyColors = {
    'cardiologue': Color(0xFFEF5350),
    'généraliste': Color(0xFF4CAF50),
    'dentiste': Color(0xFF29B6F6),
    'ophtalmologue': Color(0xFF7E57C2),
    'dermatologue': Color(0xFFFF9800),
    'pédiatre': Color(0xFFEC407A),
    'gynécologue': Color(0xFFAB47BC),
    'neurologue': Color(0xFF26C6DA),
    'psychiatre': Color(0xFF8D6E63),
  };

  Color _getSpecialtyColor(String specialty) {
    return _specialtyColors[specialty.toLowerCase()] ?? AppTheme.accentBlue;
  }

  IconData _getSpecialtyIcon(String specialty) {
    return _specialtyIcons[specialty.toLowerCase()] ?? Icons.local_hospital_rounded;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          if (_appointments.isEmpty)
            _buildEmpty()
          else
            ..._appointments.asMap().entries.map(
              (e) => _buildAppointmentItem(e.value, e.key),
            ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final nextAppt = _appointments.isNotEmpty ? _appointments.first : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentBlue, const Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مواعيد الطبيب',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rendez-vous Médecin',
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (nextAppt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.4)),
              ),
              child: Text(
                '${_appointments.length} RDV',
                style: GoogleFonts.poppins(
                  color: AppTheme.accentBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(DoctorAppointment appointment, int index) {
    final color = _getSpecialtyColor(appointment.specialty);
    final icon = _getSpecialtyIcon(appointment.specialty);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 120),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: Key(appointment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
        ),
        onDismissed: (_) => setState(() => _appointments.remove(appointment)),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.08), AppTheme.cardBgLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Doctor avatar circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: color.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.specialty,
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _appointments.removeWhere((a) => a.id == appointment.id);
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'حذف / Supprimer',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: color),
                          const SizedBox(width: 4),
                          Text(
                            appointment.time,
                            style: GoogleFonts.poppins(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.date,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppTheme.accentBlue.withOpacity(0.3), size: 40),
            const SizedBox(height: 8),
            Text(
              'لا توجد مواعيد\nAucun rendez-vous',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _showAddAppointmentDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentBlue.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'إضافة موعد / Ajouter un RDV',
                style: GoogleFonts.poppins(
                  color: AppTheme.accentBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentBlue, const Color(0xFF0097A7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'موعد جديد',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'اسم الطبيب / Nom du docteur',
                      labelStyle: GoogleFonts.poppins(color: Colors.white54),
                      prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.accentBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: specialtyController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'التخصص / Spécialité',
                      labelStyle: GoogleFonts.poppins(color: Colors.white54),
                      prefixIcon: const Icon(Icons.medical_services_rounded,
                          color: AppTheme.accentBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date picker
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setDialogState(() => selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.accentBlue),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text('changer',
                              style: GoogleFonts.poppins(
                                  color: AppTheme.accentBlue, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Time picker
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: selectedTime);
                      if (time != null) setDialogState(() => selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppTheme.accentBlue),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.format(context),
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text('changer',
                              style: GoogleFonts.poppins(
                                  color: AppTheme.accentBlue, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('إلغاء',
                              style: GoogleFonts.poppins(color: Colors.white54)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                          ),
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              setState(() {
                                _appointments.add(DoctorAppointment(
                                  id: DateTime.now().toString(),
                                  doctorName: nameController.text,
                                  specialty: specialtyController.text.isEmpty
                                      ? 'généraliste'
                                      : specialtyController.text,
                                  date: DateFormat('dd MMM yyyy').format(selectedDate),
                                  time: selectedTime.format(context),
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Text('حفظ', style: GoogleFonts.poppins()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
