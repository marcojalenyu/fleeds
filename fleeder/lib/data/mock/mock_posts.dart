import 'package:fleeder/data/models/post.dart';

final List<Post> mockPosts = [
  for (int i = 1; i <= 20; i++)
    Post(
      id: '$i',
      authorId: 'user2',
      content: 'This is the content of post #$i from user2.',
      createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
    ),
];
