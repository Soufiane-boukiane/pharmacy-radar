import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../bloc/language_bloc.dart';
import '../../services/translation_service.dart';

class AdminSmartScanWidget extends StatefulWidget {
  final Function(Map<String, dynamic> results) onScanComplete;

  const AdminSmartScanWidget({Key? key, required this.onScanComplete}) : super(key: key);

  @override
  State<AdminSmartScanWidget> createState() => _AdminSmartScanWidgetState();
}

class _AdminSmartScanWidgetState extends State<AdminSmartScanWidget> {
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _processImage(image);
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock results - In a real app, this would come from an AI API
    final mockResults = {
      'pharmacyName': 'Pharmacie Habitat',
      'startDate': DateTime.now(),
      'endDate': DateTime.now().add(const Duration(days: 7)),
      'type': 'Night Duty',
    };

    setState(() {
      _isProcessing = false;
    });

    widget.onScanComplete(mockResults);
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.15),
            AppTheme.accentGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translations.getText('smart_scan', l),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      l == 'fr' ? 'Upload duty schedule photo to auto-fill' : 'ارفع صورة جدول الحراسة للتعبئة التلقائية',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isProcessing)
            Column(
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.accentGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  Translations.getText('extracting', l),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(Translations.getText('scan_photo', l)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
