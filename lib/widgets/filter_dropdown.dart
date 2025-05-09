import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class FilterDropdown extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: AppConstants.bodyText1.copyWith(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppConstants.primaryColor),
        filled: true,
        fillColor: AppConstants.white,
        border: OutlineInputBorder(
          borderRadius: AppConstants.buttonBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.buttonBorderRadius,
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.buttonBorderRadius,
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
    );
  }
}
