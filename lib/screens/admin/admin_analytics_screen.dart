import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../bloc/admin_analytics_bloc.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminAnalyticsBloc>().add(const FetchAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentGreen,
            ),
          );
        } else if (state is AnalyticsLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Pharmacies',
                      state.totalPharmacies.toString(),
                      Icons.local_pharmacy,
                    ),
                    _buildStatCard(
                      'Active Duty',
                      state.activeDutySchedules.toString(),
                      Icons.schedule,
                    ),
                    _buildStatCard(
                      'Admin Users',
                      state.totalAdminUsers.toString(),
                      Icons.people,
                    ),
                    _buildStatCard(
                      'Activities',
                      state.recentActivities.toString(),
                      Icons.history,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is AnalyticsError) {
          return Center(
            child: Text(
              state.message,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.accentGreen,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
