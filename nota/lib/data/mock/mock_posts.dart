import 'package:nota/data/models/post.dart';

final List<Post> mockPosts = [
  Post(
    id: '1',
    authorId: 'user1',
    content: 'This is the content of the first post.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    
  ),
  Post(
    id: '2',
    authorId: 'user2',
    content: 'This is the content of the second post.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
];