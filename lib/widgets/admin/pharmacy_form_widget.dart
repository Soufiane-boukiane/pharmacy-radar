import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/pharmacy.dart';

class PharmacyFormWidget extends StatefulWidget {
  final Pharmacy? pharmacy;
  final Function(Pharmacy pharmacy) onSubmit;

  const PharmacyFormWidget({
    Key? key,
    this.pharmacy,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<PharmacyFormWidget> createState() => _PharmacyFormWidgetState();
}

class _PharmacyFormWidgetState extends State<PharmacyFormWidget> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late TextEditingController openingHoursController;
  late TextEditingController websiteController;
  late bool isOpen;
  late bool isDuty;
  late bool isDayDuty;
  late bool isPermanent;
  String? dutyStartTime;
  String? dutyEndTime;
  late String scheduleType;

  @override
  void initState() {
    super.initState();
    if (widget.pharmacy != null) {
      nameController = TextEditingController(text: widget.pharmacy!.name);
      addressController = TextEditingController(text: widget.pharmacy!.address);
      phoneController = TextEditingController(text: widget.pharmacy!.phone);
      latitudeController = TextEditingController(text: widget.pharmacy!.latitude.toString());
      longitudeController = TextEditingController(text: widget.pharmacy!.longitude.toString());
      openingHoursController = TextEditingController(text: widget.pharmacy!.openingHours ?? '');
      websiteController = TextEditingController(text: widget.pharmacy!.website ?? '');
      isOpen = widget.pharmacy!.isOpen;
      isDuty = widget.pharmacy!.isDuty;
      isDayDuty = widget.pharmacy!.isDayDuty;
      isPermanent = widget.pharmacy!.isPermanent;
      dutyStartTime = widget.pharmacy!.dutyStartTime ?? '22:00';
      dutyEndTime = widget.pharmacy!.dutyEndTime ?? '08:00';
      scheduleType = widget.pharmacy!.scheduleType;
    } else {
      nameController = TextEditingController();
      addressController = TextEditingController();
      phoneController = TextEditingController();
      latitudeController = TextEditingController();
      longitudeController = TextEditingController();
      openingHoursController = TextEditingController();
      websiteController = TextEditingController();
      isOpen = true;
      isDuty = false;
      isDayDuty = false;
      isPermanent = false;
      dutyStartTime = '22:00';
      dutyEndTime = '08:00';
      scheduleType = 'normal';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    openingHoursController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse((isStart ? dutyStartTime : dutyEndTime)!.split(':')[0]),
        minute: int.parse((isStart ? dutyStartTime : dutyEndTime)!.split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentGreen,
              onPrimary: Colors.white,
              surface: AppTheme.cardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          dutyStartTime = formatted;
        } else {
          dutyEndTime = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(28),
      ),
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
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_business_rounded, color: AppTheme.accentGreen),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.pharmacy == null ? 'Add New Pharmacy' : 'Edit Pharmacy',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('General Information'),
            _buildTextField('Pharmacy Name', nameController, icon: Icons.store_rounded),
            _buildTextField('Address', addressController, icon: Icons.location_on_rounded),
            _buildTextField('Phone Number', phoneController, icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),
            _buildSectionHeader('Location (GPS)'),
            Row(
              children: [
                Expanded(child: _buildTextField('Latitude', latitudeController, icon: Icons.map_rounded, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Longitude', longitudeController, icon: Icons.map_rounded, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Status & Duty Schedule (GMT+1)'),
            DropdownButtonFormField<String>(
              value: scheduleType,
              items: [
                DropdownMenuItem(value: 'normal', child: Text('Normal (09h-13h, 15h-19h)', style: GoogleFonts.poppins(color: Colors.white))),
                DropdownMenuItem(value: 'continuous', child: Text('Continue (09h-23h)', style: GoogleFonts.poppins(color: Colors.white))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => scheduleType = val);
              },
              decoration: InputDecoration(
                labelText: 'Schedule Type',
                labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              dropdownColor: AppTheme.cardBgLight,
            ),
            const SizedBox(height: 16),
            _buildTextField('Opening Hours', openingHoursController, icon: Icons.access_time_rounded, hint: 'e.g., 08:00 - 22:00'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTimePickerCard('Starts', dutyStartTime ?? '22:00', () => _selectTime(context, true))),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePickerCard('Ends', dutyEndTime ?? '08:00', () => _selectTime(context, false))),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchTile('Open Now', isOpen, (val) => setState(() => isOpen = val)),
            _buildSwitchTile('Night Duty (Garde Nuit)', isDuty, (val) => setState(() => isDuty = val)),
            _buildSwitchTile('Daytime Duty (Garde Jour)', isDayDuty, (val) => setState(() => isDayDuty = val)),
            _buildSwitchTile('Permanent (24/7)', isPermanent, (val) => setState(() => isPermanent = val)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Pharmacy', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard(String label, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppTheme.accentGreen),
                const SizedBox(width: 8),
                Text(time, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.accentGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 12),
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.accentGreen.withOpacity(0.5), size: 20) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentGreen, width: 1)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile.adaptive(
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentGreen,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _submitForm() {
    if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
      final pharmacy = Pharmacy(
        id: widget.pharmacy?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        address: addressController.text,
        phone: phoneController.text,
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        isOpen: isOpen,
        isDuty: isDuty,
        isDayDuty: isDayDuty,
        isPermanent: isPermanent,
        openingHours: openingHoursController.text,
        website: websiteController.text,
        dutyStartTime: dutyStartTime,
        dutyEndTime: dutyEndTime,
        scheduleType: scheduleType,
      );
      widget.onSubmit(pharmacy);
      Navigator.pop(context);
    }
  }
}
