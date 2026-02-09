import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/dtos/post_dto.dart';
import 'package:fleeds/domain/repositories/post_repository.dart';

/// Implementation of PostRepository that interacts with Firestore to fetch and manipulate post data.
class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl();

  @override
  Future<PostDTO?> fetchPost(String postId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return PostDTO.fromFirestore(doc.id, data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PostDTO>> fetchPostsByKeyword({List<String> keywords = const []}) async {
    try {
      final query = await FirebaseFirestore.instance.collection('posts').get();
      // Initial filtering to exclude deleted posts and replies
      List<PostDTO> posts = query.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data()))
        .where((post) => !post.deleted && post.repliedToPostId.isEmpty)
        .toList();
      // Sort posts by creation date (newest first)
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Further filter by keywords if provided
      if (keywords.isNotEmpty) {
        posts = posts.where((post) {
          return keywords.any((keyword) => 
            post.content
              .toLowerCase()
              .contains(keyword));
        }).toList();
      }
      return posts;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PostDTO>> fetchPostsByUser(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .where('deleted', isEqualTo: false)
          .get();
      return query.docs
          .map((doc) => PostDTO.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PostDTO>> fetchPostsLikedByUser(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
        .collection('posts')
        .where('likes', arrayContains: userId)
        .get();
      return query.docs
          .map((doc) => PostDTO.fromFirestore(doc.id, doc.data()))
          .where((post) => !post.deleted)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PostDTO>> fetchReplies(String postId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('repliedToPostId', isEqualTo: postId)
          .where('deleted', isEqualTo: false)
          .get();
      return query.docs
          .map((doc) => PostDTO.fromFirestore(doc.id, doc.data()))
          .where((post) => !post.deleted)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String?> addPost(String content, String authorId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    try {
      await docRef.set({
        'authorId': authorId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
        'deleted': false,
        'repliedToPostId': '',
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> addReply(String content, String authorId, String repliedToPostId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    final parentRef = FirebaseFirestore.instance.collection('posts').doc(repliedToPostId);
    try {
      await docRef.set({
        'authorId': authorId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
        'deleted': false,
        'repliedToPostId': repliedToPostId,
      });
      await parentRef.update({
        'comments': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>?> toggleLike(String postId, String userId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    try {
      final doc = await docRef.get();
      final data = doc.data();
      if (data == null) return null;
      final List<dynamic> likes = data['likes'] ?? [];
      final bool alreadyLiked = likes.contains(userId);
      if (alreadyLiked) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return likes.where((id) => id != userId).cast<String>().toList();
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return [...likes.cast<String>(), userId];
      }
    } catch (e) {
      return null;
    }
  }
}