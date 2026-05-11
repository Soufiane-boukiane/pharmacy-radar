import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sefrou_smart_city/theme/app_theme.dart';
import 'package:sefrou_smart_city/bloc/pharmacy_bloc.dart';
import 'package:sefrou_smart_city/bloc/duty_bloc.dart';
import 'package:sefrou_smart_city/bloc/search_bloc.dart';
import 'package:sefrou_smart_city/bloc/favorites_bloc.dart';
import 'package:sefrou_smart_city/bloc/language_bloc.dart';
import 'package:sefrou_smart_city/services/translation_service.dart';
import 'package:sefrou_smart_city/widgets/search_bar_widget.dart';
import 'package:sefrou_smart_city/widgets/filter_chips_widget.dart';
import 'package:sefrou_smart_city/models/pharmacy.dart';
import 'package:sefrou_smart_city/models/duty_schedule.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({Key? key}) : super(key: key);

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageBloc>().state;
    final l = langState.languageCode;

    return BlocBuilder<PharmacyBloc, PharmacyState>(
      builder: (context, pharmacyState) {
        return BlocBuilder<DutyBloc, DutyState>(
          builder: (context, dutyState) {
            return BlocBuilder<SearchBloc, SearchState>(
              builder: (context, searchState) {
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favoritesState) {
                    if (pharmacyState is PharmacyLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentGreen,
                        ),
                      );
                    } else if (pharmacyState is PharmacyLoaded) {
                      Pharmacy? activeDutyPharmacy;
                      if (dutyState is DutyLoaded && dutyState.currentDutyPharmacy != null) {
                        try {
                          final String targetId = dutyState.currentDutyPharmacy!.pharmacyId;
                          activeDutyPharmacy = pharmacyState.pharmacies.firstWhere(
                            (p) => p.id == targetId,
                          );
                        } catch (_) {
                          // Fallback to the one from PharmacyBloc if not found in list
                          activeDutyPharmacy = pharmacyState.dutyPharmacy;
                        }
                      } else {
                        activeDutyPharmacy = pharmacyState.dutyPharmacy;
                      }

                      final displayPharmacies = searchState is SearchLoaded
                          ? searchState.results
                          : pharmacyState.pharmacies;

                      final favoriteIds = favoritesState is FavoritesLoaded
                          ? favoritesState.favoriteIds
                          : <String>{};

                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (activeDutyPharmacy != null)
                                _buildDutyPharmacyCard(activeDutyPharmacy, favoriteIds, context, l)
                              else
                                Column(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 64),
                                    const SizedBox(height: 16),
                                    Text(
                                      l == 'ar' ? 'لا توجد صيدلية حراسة حالياً' : 'Aucune pharmacie de garde',
                                      style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 16),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    } else if (pharmacyState is PharmacyError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.accentGreen,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              pharmacyState.message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<PharmacyBloc>()
                                    .add(const FetchPharmacies());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDutyPharmacyCard(Pharmacy pharmacy, Set<String> favoriteIds, BuildContext context, String l) {
    final bool isDay = pharmacy.isDayDuty && !pharmacy.isDuty;
    final Color primaryColor = isDay ? AppTheme.accentOrange : AppTheme.primaryGreen;
    final Color secondaryColor = isDay ? Colors.orangeAccent : AppTheme.accentGreen;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.8),
            secondaryColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.mountainWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mountainWhite.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isDay ? 'DAY DUTY / حراسة نهارية' : Translations.getText('duty_pharmacy', l),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mountainWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pharmacy.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.mountainWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pharmacy.address,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.mountainWhite.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: Text(Translations.getText('call', l)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mountainWhite,
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  label: Text(Translations.getText('map', l)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mountainWhite.withValues(alpha: 0.2),
                    foregroundColor: AppTheme.mountainWhite,
                    side: BorderSide(
                      color: AppTheme.mountainWhite.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy, bool isFavorite, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassDecoration(
        color: AppTheme.accentGreen,
        opacity: 0.05,
        borderRadius: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pharmacy.address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? AppTheme.accentGreen.withValues(alpha: 0.2)
                        : AppTheme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        context.read<FavoritesBloc>().add(RemoveFavorite(pharmacy.id));
                      } else {
                        context.read<FavoritesBloc>().add(AddFavorite(pharmacy.id));
                      }
                    },
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    color: isFavorite ? AppTheme.accentGreen : AppTheme.textSecondary,
                    iconSize: 24,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (pharmacy.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accentGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pharmacy.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        iconSize: 18,
                        color: AppTheme.accentBlue,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        iconSize: 18,
                        color: AppTheme.accentGreen,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
