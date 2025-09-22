class Post {
  final String _id;
  final String _authorId;
  
  String _title;
  String _content;
  String? _imageUrl;
  final DateTime? _createdAt;
  DateTime? _updatedAt;
  bool deleted = false;

  String get title => _title;
  String get content => _content;

  Post({
    required String id,
    required String authorId,
    String title = '',
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : 
    _id = id,
    _authorId = authorId,
    _title = title,
    _content = content,
    _createdAt = createdAt,
    _updatedAt = updatedAt;

}