import 'package:flutter/material.dart';

/// A panel widget that provides search functionality.
class SearchPanel extends StatefulWidget {
  
  final void Function(String) _onSearch;
  final List<String> _results;

  const SearchPanel({
    super.key,
    required void Function(String) onSearch,
    required List<String> results,
  }) : _results = results,
       _onSearch = onSearch;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

/// State class for SearchPanel.
class _SearchPanelState extends State<SearchPanel> {
  
  final TextEditingController _controller = TextEditingController();

  /// Formulates the search query and navigates to Home with keywords as arguments.
  void _formulateSearch(String query) {
    if (query.trim().isNotEmpty) {
      final keywords = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'));
      Navigator.of(
        context,
      ).pushReplacementNamed('/', arguments: keywords);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24), // Circular box
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
              onSubmitted: _formulateSearch,
              onChanged: widget._onSearch,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget._results.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(widget._results[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
