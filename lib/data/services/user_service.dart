import 'package:fleeds/data/dtos/user_dto.dart';
import 'package:fleeds/data/repositories/user_repository_impl.dart';
import 'package:fleeds/data/services/notification_service.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/domain/repositories/user_repository.dart';

/// Service layer that handles business logic, maps DTOs to domain models, and orchestrates repository calls.
class UserService {
  final UserRepository _repository;
  final NotificationService _notificationService;

  const UserService({UserRepository? repository, NotificationService? notificationService})
      : _repository = repository ?? const UserRepositoryImpl(),
        _notificationService = notificationService ?? const NotificationService();

  User _mapDtoToDomain(UserDTO dto) {
    return User(
      id: dto.id,
      username: dto.username,
      displayName: dto.displayName,
      bio: dto.bio,
      avatarUrl: dto.avatarUrl,
      avatarColor: dto.avatarColor,
      avatarBgColor: dto.avatarBgColor,
      bannerUrl: dto.bannerUrl,
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

  Future<User?> updateUsername(String userId, String newUsername) async {
    final dto = await _repository.updateUsername(userId, newUsername);
    if (dto == null) return null;
    return _mapDtoToDomain(dto);
  }

  Future<User?> updateUserProfile(String userId, {
    String? displayName, 
    String? bio, 
    String? avatarUrl, 
    String? avatarColor, 
    String? avatarBgColor, 
    String? bannerUrl
  }) async {
    final dto = await _repository.updateUserProfile(userId, displayName: displayName, bio: bio, avatarUrl: avatarUrl, avatarColor: avatarColor, avatarBgColor: avatarBgColor, bannerUrl: bannerUrl);
    if (dto == null) return null;
    return _mapDtoToDomain(dto);
  }

  Future<List<String>?> toggleFollow(String currentUserId, String currentUsername, String targetUserId) async {
    final result = await _repository.toggleFollow(currentUserId, targetUserId);
    if (result != null && result.contains(targetUserId)) {
      await _notificationService.addNotification(
        type: 'follow', 
        targetUserId: targetUserId,
        triggeredByUsername: currentUsername,
        triggeredByUserId: currentUserId,
      );
    }
    return result;
  }

  Future<List<String>?> removeFollower(String userId, String followerId) async {
    return await _repository.removeFollower(userId, followerId);
  }
}


