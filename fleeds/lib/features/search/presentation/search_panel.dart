import 'package:flutter/material.dart';

class SearchPanel extends StatefulWidget {
  final void Function(String) onSearch;
  final List<String> results;

  const SearchPanel({super.key, required this.onSearch, required this.results});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();

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
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  final keywords = query.trim().split(RegExp(r'\s+'));
                  Navigator.of(context).pushReplacementNamed(
                    '/',
                    arguments: keywords,
                  );
                }
              },
              onChanged: widget.onSearch,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.results[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


