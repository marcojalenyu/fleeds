import 'package:fleeds/data/dtos/user_dto.dart';
import 'package:fleeds/data/repositories/user_repository_impl.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/domain/repositories/user_repository.dart';

/// Service layer that handles business logic, maps DTOs to domain models, and orchestrates repository calls.
class UserService {
  final UserRepository _repository;

  const UserService({UserRepository? repository})
      : _repository = repository ?? const UserRepositoryImpl();

  User _mapDtoToDomain(UserDTO dto) {
    return User(
      id: dto.id,
      username: dto.username,
      displayName: dto.displayName,
      bio: dto.bio,
      avatarUrl: dto.avatarUrl,
      followers: List<String>.from(dto.followers),
      following: List<String>.from(dto.following),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
  
  Future<User?> fetchUser(String userId) async {
    final dto = await _repository.fetchUser(userId);
    if (dto == null) return null;
    return _mapDtoToDomain(dto);
  }

  Future<List<User>> fetchFollowers(String userId) async {
    final dtos = await _repository.fetchFollowers(userId);
    if (dtos == null) return [];
    return dtos.map(_mapDtoToDomain).toList();
  }

  Future<List<User>> fetchFollowing(String userId) async {
    final dtos = await _repository.fetchFollowing(userId);
    if (dtos == null) return [];
    return dtos.map(_mapDtoToDomain).toList();
  }

  Future<User?> updateUserProfile(String userId, {String? username, String? bio, String? avatarUrl}) async {
    final dto = await _repository.updateUserProfile(userId, username: username, bio: bio, avatarUrl: avatarUrl);
    if (dto == null) return null;
    return _mapDtoToDomain(dto);
  }

  Future<List<String>?> toggleFollow(String currentUserId, String targetUserId) async {
    return await _repository.toggleFollow(currentUserId, targetUserId);
  }

  Future<List<String>?> removeFollower(String userId, String followerId) async {
    return await _repository.removeFollower(userId, followerId);
  }
}


