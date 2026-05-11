import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'pharmacy_screen.dart';
import 'map_screen.dart';
import 'dashboard_screen.dart';
import 'government_map_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/language_bloc.dart';
import '../services/translation_service.dart';
import 'admin/admin_home_screen.dart';
import 'auth/login_screen.dart';
import 'emergency_contacts_screen.dart';
import 'map_3d_simulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    final List<Widget> screens = [
      const DashboardScreen(),
      const MapScreen(),
      const GovernmentMapScreen(),
    ];

    final List<String> titles = [
      l == 'ar' ? 'الرئيسية' : (l == 'fr' ? 'Accueil' : 'Home'),
      l == 'ar' ? 'الصيدليات' : (l == 'fr' ? 'Pharmacies' : 'Pharmacies'),
      l == 'ar' ? 'المرافق العمومية' : (l == 'fr' ? 'Services Publics' : 'Public Services'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.cardBg,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (code) {
              context.read<LanguageBloc>().add(ChangeLanguage(code));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'fr', child: Text('Français')),
              const PopupMenuItem(value: 'ar', child: Text('العربية')),
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'es', child: Text('Español')),
            ],
          ),
        ],
      ),
      drawer: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          return Drawer(
            backgroundColor: AppTheme.darkBg,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.accentGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.mountainWhite,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.mountainWhite,
                          child: Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? (l == 'fr' ? 'Utilisateur' : 'مستخدم'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.accentGreen),
                  title: Text(
                    _getLanguageName(l),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emergency, color: Colors.redAccent),
                  title: Text(
                    l == 'ar' ? 'أرقام الطوارئ' : (l == 'fr' ? 'Numéros d\'urgence' : 'Emergency Contacts'),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
                    );
                  },
                ),
                if (user?.isAdmin ?? false)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: AppTheme.accentGreen),
                    title: Text(
                      Translations.getText('admin_dashboard', l),
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
                      );
                    },
                  ),
                if (user != null)
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      Translations.getText('logout', l),
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(const AuthSignOut());
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.login, color: AppTheme.accentGreen),
                    title: Text(
                      Translations.getText('login', l),
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: AppTheme.cardBg,
          selectedItemColor: AppTheme.accentGreen,
          unselectedItemColor: AppTheme.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l == 'ar' ? 'الرئيسية' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.local_pharmacy_outlined, size: 28),
              activeIcon: const Icon(Icons.local_pharmacy, size: 32),
              label: l == 'ar' ? 'الصيدليات' : 'Pharmacies',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_outlined, size: 20),
              activeIcon: const Icon(Icons.account_balance, size: 22),
              label: l == 'ar' ? 'المرافق' : 'Services',
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text(
          'Select Language / اختر اللغة',
          style: GoogleFonts.poppins(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'fr', 'Français'),
            _languageOption(context, 'ar', 'العربية'),
            _languageOption(context, 'en', 'English'),
            _languageOption(context, 'es', 'Español'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String code, String name) {
    return ListTile(
      title: Text(
        name,
        style: GoogleFonts.poppins(color: AppTheme.textPrimary),
      ),
      onTap: () {
        context.read<LanguageBloc>().add(ChangeLanguage(code));
        Navigator.pop(context);
      },
    );
  }
}
