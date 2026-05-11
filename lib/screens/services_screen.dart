import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../bloc/language_bloc.dart';
import '../services/translation_service.dart';
import '../widgets/emergency_contacts_widget.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getLocalizedServices(String l) {
    return [
      {
        'title': Translations.getText('transport', l),
        'icon': Icons.directions_bus,
        'color': AppTheme.accentBlue,
        'items': [
          {'name': Translations.getText('urban_bus', l), 'phone': '+212 5XX XXX XXX'},
          {'name': Translations.getText('taxi', l), 'phone': '+212 5XX XXX XXX'},
        ],
      },
      {
        'title': Translations.getText('healthcare', l),
        'icon': Icons.local_hospital,
        'color': AppTheme.purpleLight,
        'items': [
          {'name': Translations.getText('hospital', l), 'phone': '+212 5XX XXX XXX'},
          {'name': Translations.getText('clinic', l), 'phone': '+212 5XX XXX XXX'},
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;
    final services = _getLocalizedServices(l);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Translations.getText('services', l),
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              Translations.getText('quick_access', l),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            EmergencyContactsWidget(),
            const SizedBox(height: 24),
            ...services.asMap().entries.map((entry) => _buildServiceCard(entry.value, entry.key)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Icon(service['icon'] as IconData, color: service['color'] as Color),
        title: Text(service['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        children: (service['items'] as List<Map<String, String>>).map((item) {
          return ListTile(
            title: Text(item['name']!, style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: AppTheme.accentGreen),
              onPressed: () {},
            ),
          );
        }).toList(),
      ),
    );
  }
}
