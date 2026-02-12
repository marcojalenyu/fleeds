import '../../data/dtos/user_dto.dart';

abstract class UserRepository {
  Future<UserDTO?> fetchUser(String userId);
  Future<List<UserDTO>?> fetchFollowers(String userId);
  Future<List<UserDTO>?> fetchFollowing(String userId);
  Future<UserDTO?> updateUserProfile(String userId, {String? displayName, String? bio, String? avatarUrl});
  Future<List<String>?> toggleFollow(String currentUserId, String targetUserId);
  Future<List<String>?> removeFollower(String userId, String followerId);
}