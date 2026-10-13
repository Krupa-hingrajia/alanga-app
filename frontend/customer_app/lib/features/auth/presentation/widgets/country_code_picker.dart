import 'package:flutter/material.dart';

class CountryInfo {
  final String name;
  final String dialCode;
  final String code;
  final String flag;

  const CountryInfo({
    required this.name,
    required this.dialCode,
    required this.code,
    required this.flag,
  });
}

const List<CountryInfo> supportedCountries = [
  CountryInfo(name: 'India', dialCode: '+91', code: 'IN', flag: '🇮🇳'),
  CountryInfo(name: 'United Arab Emirates', dialCode: '+971', code: 'AE', flag: '🇦🇪'),
  CountryInfo(name: 'Sri Lanka', dialCode: '+94', code: 'LK', flag: '🇱🇰'),
  CountryInfo(name: 'Saudi Arabia', dialCode: '+966', code: 'SA', flag: '🇸🇦'),
  CountryInfo(name: 'Qatar', dialCode: '+974', code: 'QA', flag: '🇶🇦'),
  CountryInfo(name: 'Oman', dialCode: '+968', code: 'OM', flag: '🇴🇲'),
  CountryInfo(name: 'Kuwait', dialCode: '+965', code: 'KW', flag: '🇰🇼'),
  CountryInfo(name: 'Bahrain', dialCode: '+973', code: 'BH', flag: '🇧🇭'),
  CountryInfo(name: 'United States', dialCode: '+1', code: 'US', flag: '🇺🇸'),
  CountryInfo(name: 'United Kingdom', dialCode: '+44', code: 'GB', flag: '🇬🇧'),
  CountryInfo(name: 'Canada', dialCode: '+1', code: 'CA', flag: '🇨🇦'),
  CountryInfo(name: 'Australia', dialCode: '+61', code: 'AU', flag: '🇦🇺'),
  CountryInfo(name: 'Singapore', dialCode: '+65', code: 'SG', flag: '🇸🇬'),
  CountryInfo(name: 'Malaysia', dialCode: '+60', code: 'MY', flag: '🇲🇾'),
  CountryInfo(name: 'Bangladesh', dialCode: '+880', code: 'BD', flag: '🇧🇩'),
  CountryInfo(name: 'Nepal', dialCode: '+977', code: 'NP', flag: '🇳🇵'),
  CountryInfo(name: 'Pakistan', dialCode: '+92', code: 'PK', flag: '🇵🇰'),
  CountryInfo(name: 'Germany', dialCode: '+49', code: 'DE', flag: '🇩🇪'),
  CountryInfo(name: 'France', dialCode: '+33', code: 'FR', flag: '🇫🇷'),
];

class CountryCodePickerButton extends StatelessWidget {
  final CountryInfo selectedCountry;
  final ValueChanged<CountryInfo> onCountryChanged;

  const CountryCodePickerButton({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet<CountryInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerBottomSheet(
        selectedCountry: selectedCountry,
      ),
    ).then((selected) {
      if (selected != null) {
        onCountryChanged(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1DDD6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCountry.dialCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF11261B),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Color(0xFF4C6656),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerBottomSheet extends StatefulWidget {
  final CountryInfo selectedCountry;

  const _CountryPickerBottomSheet({required this.selectedCountry});

  @override
  State<_CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<_CountryPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryInfo> _filteredCountries = supportedCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = supportedCountries;
      } else {
        _filteredCountries = supportedCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.toLowerCase().contains(query) ||
              c.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7 + viewInsets.bottom,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1DDD6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Country Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search country or code...',
              hintStyle: const TextStyle(color: Color(0xFF7A9A86), fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF7A9A86)),
              filled: true,
              fillColor: const Color(0xFFF1F5F2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCountries.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE4ECE8)),
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.dialCode == widget.selectedCountry.dialCode &&
                    country.code == widget.selectedCountry.code;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: const Color(0xFF11261B),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF1A3827) : const Color(0xFF7A9A86),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, size: 18, color: Color(0xFF1A3827)),
                      ],
                    ],
                  ),
                  onTap: () => Navigator.of(context).pop(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
