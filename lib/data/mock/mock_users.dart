import 'package:fleeds/data/dtos/user_dto.dart';

final List<UserDTO> mockUsers = [
  UserDTO(
    id: 'user1',
    username: 'johndoe',
    displayName: 'John Doe',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  UserDTO(
    id: 'user2',
    username: 'alicesmith',
    displayName: 'Alice Smith',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];


