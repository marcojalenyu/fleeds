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
Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsByKeyword({
  List<String> keywords = const [],
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
      .collection('posts')
      .where('repliedToPostId', isEqualTo: '') // May include replies in feed in the future
      .where('deleted', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    List<PostDTO> posts = snapshot.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    // Simple client-side filtering for keywords in content (Firestore doesn't support full-text search)
    // May result in less efficient queries, consider integrating a search service for production use
    if (keywords.isNotEmpty) {
      posts = posts.where((post) {
        return keywords.any((keyword) => 
          post.content.toLowerCase().contains(keyword.toLowerCase()));
      }).toList(); 
    }

    DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (posts: posts, lastDoc: lastDoc);
  } catch (e) {
    return (posts: <PostDTO>[], lastDoc: null);
  }
}

@override
Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsByUser({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .where('repliedToPostId', isEqualTo: '') // Replies have a separate fetch method
        .where('deleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    final posts = snapshot.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (posts: posts, lastDoc: lastDoc);
  } catch (e) {
    return (posts: <PostDTO>[], lastDoc: null);
  }
}

@override
Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsLikedByUser({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('likes', arrayContains: userId)
        .where('deleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    final posts = snapshot.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (posts: posts, lastDoc: lastDoc);
  } catch (e) {
    return (posts: <PostDTO>[], lastDoc: null);
  }
}

@override
Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchRepliesByUser({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .where('repliedToPostId', isNotEqualTo: '') // Only fetch replies
        .where('deleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    final posts = snapshot.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (posts: posts, lastDoc: lastDoc);
  } catch (e) {
    return (posts: <PostDTO>[], lastDoc: null);
  }
}

@override
Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchReplies({
  required String postId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('repliedToPostId', isEqualTo: postId)
        .where('deleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    
    final posts = snapshot.docs
        .map((doc) => PostDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (posts: posts, lastDoc: lastDoc);
  } catch (e) {
    return (posts: <PostDTO>[], lastDoc: null);
  }
}

  @override
  Future<String?> addPost(String content, String authorId, String? mediaUrl) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc();
    try {
      await docRef.set({
        'authorId': authorId,
        'content': content,
        'mediaUrl': mediaUrl,
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
        'mediaUrl': null,
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