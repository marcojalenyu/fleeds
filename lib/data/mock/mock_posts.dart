import 'package:fleeds/data/dtos/post_dto.dart';

final List<PostDTO> mockPosts = [
  for (int i = 1; i <= 20; i++)
    PostDTO(
      id: '$i',
      authorId: 'user2',
      content: 'This is the content of post #$i from user2.',
      createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
    ),
];


