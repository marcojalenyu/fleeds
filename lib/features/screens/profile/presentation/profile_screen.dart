import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/features/components/profile/presentation/profile.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/features/screens/profile/logic/profile_controller.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:fleeds/features/components/post/presentation/post_list.dart';

/// ProfileScreen displays a user's profile with their posts, replies, and liked posts.
class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProfileController? _profileController;
  final _postController = PostController();
  final _repliesController = PostController();
  final _likedController = PostController();
  List<Post> _posts = [];
  List<Post> _replies = [];
  List<Post> _likedPosts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initProfileController();
  }

  Future<void> _initProfileController() async {
    final userId = widget.userId ?? '';
    _profileController = await ProfileController.initialize(userId);
    _fetchUserPosts(_profileController!.userOnProfile!.id);
    _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
    setState(() => _loading = false);
  }

  void _fetchUserPosts(String userId) async {
    final allPosts = await _postController.fetchPostsByUser(userId: userId, refresh: true);
    final posts = allPosts.where((post) => !post.isReply).toList();
    setState(() => _posts = posts);
    final allReplies = await _repliesController.fetchPostsByUser(userId: userId, refresh: true);
    final replies = allReplies.where((post) => post.isReply).toList();
    setState(() => _replies = replies);
  }

  Future<List<Post>> _loadMorePosts() async {
    final allPosts = await _postController.fetchPostsByUser(
      userId: _profileController!.userOnProfile!.id,
      refresh: false,
    );
    final posts = allPosts.where((post) => !post.isReply).toList();
    setState(() => _posts.addAll(posts));
    return posts;
  }

  void _fetchPostsLikedByUser(String userId) async {
    final likedPosts = await _likedController.fetchPostsLikedByUser(userId: userId, refresh: true);
    setState(() => _likedPosts = likedPosts);
  }

  Future<List<Post>> _loadMoreLikedPosts() async {
    final likedPosts = await _likedController.fetchPostsLikedByUser(
      userId: _profileController!.userOnProfile!.id,
      refresh: false,
    );
    setState(() => _likedPosts.addAll(likedPosts));
    return likedPosts;
  }

  Future<List<Post>> _loadMoreReplies() async {
    final replies = await _repliesController.fetchPostsByUser(
      userId: _profileController!.userOnProfile!.id,
      refresh: false,
    );
    final filteredReplies = replies.where((post) => post.isReply).toList();
    setState(() => _replies.addAll(filteredReplies));
    return filteredReplies;
  }

  void _refreshProfile() {
    if (_profileController != null) {
      _postController.resetPagination();
      _repliesController.resetPagination();
      _likedController.resetPagination();
      _fetchUserPosts(_profileController!.userOnProfile!.id);
      _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
    } else {
      _initProfileController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _repliesController.dispose();
    _likedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profileController == null) {
      return MainScaffold(
        currentIndex: 1,
        body: Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _profileController!,
            builder: (context, _) => SelectableText('@${_profileController!.userOnProfile!.username}'),
          ),
        ),
        body: AnimatedBuilder(
          animation: _profileController!,
          builder: (context, _) {
            final user = _profileController!.userOnProfile;
            return RefreshIndicator(
              onRefresh: () async => _refreshProfile(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(user: user!),
                    const SizedBox(height: 16),
                    ProfileButtonRow(controller: _profileController!),
                    ProfileStats(user: user),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Replies'),
                        Tab(text: 'Likes'),
                      ],
                    ),
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PostList(
                            initialPosts: _posts,
                            onLoadMore: _loadMorePosts,
                            onPostChanged: (_) { 
                              _fetchUserPosts(_profileController!.userOnProfile!.id);
                              _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
                            },
                          ),
                          PostList(
                            initialPosts: _replies,
                            onLoadMore: _loadMoreReplies,
                            onPostChanged: (_) {
                              _fetchUserPosts(_profileController!.userOnProfile!.id);
                              _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
                            },
                          ),
                          PostList(
                            initialPosts: _likedPosts,
                            onLoadMore: _loadMoreLikedPosts,
                            onPostChanged: (_) {
                              _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
                              _fetchUserPosts(_profileController!.userOnProfile!.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          },
        ),
      ),
    );
  }
}