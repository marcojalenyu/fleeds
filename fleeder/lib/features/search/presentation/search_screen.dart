import 'package:flutter/material.dart';
import 'search_panel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: SearchPanel(
        onSearch: (query) {},
        results: [],
      ),
    );
  }
}