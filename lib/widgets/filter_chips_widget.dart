import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FilterChipsWidget extends StatefulWidget {
  final Function(String) onFilterChanged;
  final String selectedFilter;

  const FilterChipsWidget({
    Key? key,
    required this.onFilterChanged,
    this.selectedFilter = 'all',
  }) : super(key: key);

  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<FilterChipsWidget> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Open', 'value': 'open'},
      {'label': 'Closed', 'value': 'closed'},
      {'label': 'On Duty', 'value': 'duty'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppTheme.mountainWhite
                      : AppTheme.textSecondary,
                ),
              ),
              backgroundColor: isSelected
                  ? AppTheme.accentGreen
                  : AppTheme.cardBg,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.accentGreen
                    : AppTheme.dividerColor,
                width: 1,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['value'] as String;
                });
                widget.onFilterChanged(_selectedFilter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
