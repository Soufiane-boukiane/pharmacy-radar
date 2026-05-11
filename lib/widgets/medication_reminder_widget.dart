import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/medication_reminder.dart';
import '../theme/app_theme.dart';

class MedicationReminderWidget extends StatefulWidget {
  const MedicationReminderWidget({Key? key}) : super(key: key);

  @override
  State<MedicationReminderWidget> createState() => _MedicationReminderWidgetState();
}

class _MedicationReminderWidgetState extends State<MedicationReminderWidget>
    with SingleTickerProviderStateMixin {
  final List<MedicationReminder> _reminders = [
    const MedicationReminder(id: '1', medicineName: 'Vitamin C', time: '08:00'),
    const MedicationReminder(id: '2', medicineName: 'Calcium', time: '13:00'),
  ];

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.accentGreen.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGreen.withOpacity(0.08),
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
              if (_reminders.isEmpty)
                _buildEmpty()
              else
                ..._reminders.asMap().entries.map(
                  (e) => _buildReminderItem(e.value, e.key),
                ),
              _buildAddButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentGreen, AppTheme.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تذكير الدواء',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Rappel Médicament',
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _buildPulsingBadge(_reminders.where((r) => r.isActive).length),
        ],
      ),
    );
  }

  Widget _buildPulsingBadge(int count) {
    if (count == 0) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentGreen.withOpacity(0.4)),
            ),
            child: Text(
              '$count actif',
              style: GoogleFonts.poppins(
                color: AppTheme.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderItem(MedicationReminder reminder, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(reminder.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
        ),
        onDismissed: (_) => setState(() => _reminders.remove(reminder)),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: reminder.isActive
                ? AppTheme.accentGreen.withOpacity(0.07)
                : AppTheme.cardBgLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: reminder.isActive
                  ? AppTheme.accentGreen.withOpacity(0.25)
                  : AppTheme.dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Time circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: reminder.isActive
                      ? LinearGradient(
                          colors: [
                            AppTheme.accentGreen.withOpacity(0.3),
                            AppTheme.primaryGreen.withOpacity(0.2)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: reminder.isActive ? null : AppTheme.dividerColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      reminder.time.split(':')[0],
                      style: GoogleFonts.poppins(
                        color: reminder.isActive ? AppTheme.accentGreen : Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      ':${reminder.time.split(':')[1]}',
                      style: GoogleFonts.poppins(
                        color: reminder.isActive
                            ? AppTheme.accentGreen.withOpacity(0.7)
                            : Colors.white24,
                        fontSize: 11,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: GoogleFonts.poppins(
                        color: reminder.isActive ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          reminder.isActive
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          color: reminder.isActive ? AppTheme.accentGreen : Colors.white30,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.isActive ? 'Actif / فعّال' : 'Désactivé / معطل',
                          style: GoogleFonts.poppins(
                            color: reminder.isActive
                                ? AppTheme.accentGreen.withOpacity(0.8)
                                : Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                        _reminders.removeWhere((r) => r.id == reminder.id);
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'حذف / Supprimer',
                  ),
                  Switch.adaptive(
                    value: reminder.isActive,
                    onChanged: (val) {
                      setState(() {
                        final i = _reminders.indexWhere((r) => r.id == reminder.id);
                        _reminders[i] = _reminders[i].copyWith(isActive: val);
                      });
                    },
                    activeColor: AppTheme.accentGreen,
                    inactiveThumbColor: Colors.white30,
                    inactiveTrackColor: AppTheme.dividerColor,
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
            Icon(Icons.medication_rounded, color: AppTheme.accentGreen.withOpacity(0.3), size: 40),
            const SizedBox(height: 8),
            Text(
              'لا توجد أدوية مضافة\nAucun médicament',
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
        onTap: _showAddReminderDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentGreen.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'إضافة دواء / Ajouter un médicament',
                style: GoogleFonts.poppins(
                  color: AppTheme.accentGreen,
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

  void _showAddReminderDialog() {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                          colors: [AppTheme.accentGreen, AppTheme.primaryGreen],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.medication_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'إضافة دواء',
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
                    labelText: 'اسم الدواء / Nom du médicament',
                    labelStyle: GoogleFonts.poppins(color: Colors.white54),
                    prefixIcon: const Icon(Icons.local_pharmacy_rounded, color: AppTheme.accentGreen),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
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
                        const Icon(Icons.access_time_rounded, color: AppTheme.accentGreen),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime.format(context),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'changer',
                          style: GoogleFonts.poppins(
                            color: AppTheme.accentGreen,
                            fontSize: 12,
                          ),
                        ),
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
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            setState(() {
                              _reminders.add(MedicationReminder(
                                id: DateTime.now().toString(),
                                medicineName: nameController.text,
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
    );
  }
}
