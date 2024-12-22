import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  CategoryDropdown({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      hint: Text('Select Category'),
      value: selectedCategoryId,
      onChanged: onCategorySelected,
      items: categories.map((category) {
        return DropdownMenuItem<int>(
          value: category['categorie_id'],
          child: Text(category['categorie_name']),
        );
      }).toList(),
    );
  }
}