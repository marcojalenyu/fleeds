import 'package:nota/data/models/user.dart';

final List<User> mockUsers = [
  User(
    id: 'user1',
    username: 'johndoe',
    password: '123456',
    displayName: 'John Doe',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  User(
    id: 'user2',
    username: 'alicesmith',
    password: 'password',
    displayName: 'Alice Smith',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];