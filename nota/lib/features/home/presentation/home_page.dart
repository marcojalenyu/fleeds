import 'package:flutter/material.dart';
import 'package:nota/data/mock/mock_posts.dart';
import 'package:nota/data/models/Post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showAddPostDialog(BuildContext context) {

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String content = '';
        return AlertDialog(
          title: const Text('Add New Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                title = titleController.text;
                content = contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  Navigator.of(context).pop({'title': title, 'content': content});
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          mockPosts.add(Post(
            id: DateTime.now().toString(),
            authorId: 'currentUser', // Replace with actual user ID
            title: result['title'],
            content: result['content'],
            createdAt: DateTime.now(),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home), 
          onPressed: () {

          }
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(child: Icon(Icons.person)), 
            onPressed: () {

            }
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockPosts.length,
        itemBuilder: (context, index) {
          final post = mockPosts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.content),
            onTap: () {
              // Navigate to post details
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPostDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}