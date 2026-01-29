import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/models/post.dart';

class PostService {
  static Future<Post?> fetchPost(String postId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return Post(
        id: doc.id,
        authorId: data['authorId'] ?? '',
        repliedToPostId: data['repliedToPostId'] ?? '',
        content: data['content'] ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        likes: List<String>.from(data['likes'] ?? []),
        comments: List<String>.from(data['comments'] ?? []),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<List<Post>> fetchPosts({List<String> keywords = const []}) async {
    try {
      final query = await FirebaseFirestore.instance.collection('posts').get();
      List<Post> posts = query.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          repliedToPostId: data['repliedToPostId'] ?? '',
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
          likes: List<String>.from(data['likes'] ?? []),
          comments: List<String>.from(data['comments'] ?? []),
        );
      }).where((post) => !post.deleted && !post.isAReply()).toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (keywords.isNotEmpty) {
        posts = posts.where((post) {
          return keywords.any((keyword) => post.content.contains(keyword));
        }).toList();
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Post>> fetchPostsLikedByUser(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('likes', arrayContains: userId)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          repliedToPostId: data['repliedToPostId'] ?? '',
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
          likes: List<String>.from(data['likes'] ?? []),
          comments: List<String>.from(data['comments'] ?? []),
        );
      }).where((post) => !post.deleted && !post.isAReply()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Post>> fetchReplies(String postId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('repliedToPostId', isEqualTo: postId)
          .where('deleted', isEqualTo: false)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          repliedToPostId: data['repliedToPostId'] ?? '',
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
          likes: List<String>.from(data['likes'] ?? []),
          comments: List<String>.from(data['comments'] ?? []),
        );
      }).where((post) => !post.deleted).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Post>> fetchPostsByUser(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .where('deleted', isEqualTo: false)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          authorId: data['authorId'] ?? '',
          repliedToPostId: data['repliedToPostId'] ?? '',
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
          likes: List<String>.from(data['likes'] ?? []),
          comments: List<String>.from(data['comments'] ?? []),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addPost(String content, String authorId) async {
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
        'repliedToPostId': null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> addReply(String parentPostId, String authorId, String content) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    final parentRef = FirebaseFirestore.instance.collection('posts').doc(parentPostId);

    try {
      await docRef.set({
        'authorId': authorId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
        'deleted': false,
        'repliedToPostId': parentPostId,
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

  static Future<List<String>?> toggleLike(String postId, String userId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    try {
      final doc = await docRef.get();
      final data = doc.data();
      final List<dynamic> likes = data?['likes'] ?? [];
      final bool alreadyLiked = likes.contains(userId);

      if (alreadyLiked) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Refetch likes after update for consistency
      final updatedDoc = await docRef.get();
      final updatedLikes = List<String>.from(updatedDoc.data()?['likes'] ?? []);
      return updatedLikes;
    } catch (e) {
      return null;
    }
  }
}

