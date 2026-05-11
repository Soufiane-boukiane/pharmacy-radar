import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../bloc/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmergencyContactsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name_fr': 'Police Secours',
      'name_ar': 'الشرطة - النجدة',
      'phone': '19',
      'icon': Icons.security,
    },
    {
      'name_fr': 'Gendarmerie Royale',
      'name_ar': 'الدرك الملكي',
      'phone': '177',
      'icon': Icons.admin_panel_settings,
    },
    {
      'name_fr': 'Ambulance / Pompiers',
      'name_ar': 'الإسعاف / الوقاية المدنية',
      'phone': '15',
      'icon': Icons.local_fire_department,
    },
  ];

  EmergencyContactsWidget({Key? key}) : super(key: key);

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l == 'ar' ? 'أرقام الطوارئ' : (l == 'fr' ? 'Numéros d\'urgence' : 'Emergency Contacts'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...emergencyContacts.map((contact) {
            final name = l == 'ar' ? contact['name_ar']! : contact['name_fr']!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _makeCall(contact['phone']!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        contact['icon'] as IconData,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              contact['phone']!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.call,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
