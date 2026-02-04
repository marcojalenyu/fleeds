import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/features/screens/profile/logic/profile_controller.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:fleeds/features/components/post/presentation/post_list.dart';
import 'package:fleeds/widgets/profile_btn.dart';
import 'package:fleeds/widgets/profile_pic.dart';
import 'package:fleeds/features/components/edit_profile/presentation/profile_edit_dialog.dart'; // Import where showProfileEditDialog is defined

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
    final allPosts = await _postController.fetchPostsByUser(userId);
    final posts = allPosts.where((post) => !post.isReply).toList();
    final replies = allPosts.where((post) => post.isReply).toList();
    setState(() {
      _posts = posts;
      _replies = replies;
    });
  }

  void _fetchPostsLikedByUser(String userId) async {
    final likedPosts = await _postController.fetchPostsLikedByUser(userId);
    setState(() => _likedPosts = likedPosts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profileController == null) {
      return MainScaffold(
        currentIndex: 1,
        body: Scaffold(
          appBar: AppBar(),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _profileController!,
            builder: (context, _) => Text('@${_profileController!.userOnProfile!.username}'),
          ),
        ),
        body: AnimatedBuilder(
          animation: _profileController!,
          builder: (context, _) {
            final user = _profileController!.userOnProfile;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(user: user!),
                  SizedBox(height: 16),
                  _ProfileButtonRow(controller: _profileController!),
                  _ProfileStats(user: user),
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
                          onPostChanged: (_) { 
                            _fetchUserPosts(_profileController!.userOnProfile!.id);
                            _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
                          },
                        ),
                        PostList(
                          initialPosts: _replies,
                          onPostChanged: (_) {
                            _fetchUserPosts(_profileController!.userOnProfile!.id);
                            _fetchPostsLikedByUser(_profileController!.userOnProfile!.id);
                          },
                        ),
                        PostList(
                          initialPosts: _likedPosts,
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
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  const _ProfileHeader({required this.user});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: 120, color: Colors.grey[300]),
        Positioned(
          left: 16,
          bottom: -40,
          child: ProfilePic(user: user, size: 40.0),
        ),
      ],
    );
  }
}

class _ProfileButtonRow extends StatelessWidget {
  final ProfileController controller;
  const _ProfileButtonRow({required this.controller});

  Future<void> showProfileEditDialog(BuildContext context, User user) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(user: user),
    );
    if (result != null && result['bio'] != null) {
      controller.updateProfile(result['displayName'], result['bio']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        controller.isOwnProfile
            ? ProfileBtn(
                label: 'Edit Profile',
                onPressed: () => showProfileEditDialog(context, controller.userOnProfile!),
              )
            : ProfileBtn(
                label: controller.isFollowing ? 'Unfollow' : 'Follow',
                isFollowing: controller.isFollowing,
                showHoverUnfollow: true,
                onPressed: () => controller.toggleFollowUser(controller.userOnProfile!.id),
              ),
        SizedBox(width: 16),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {

  final User user;
  const _ProfileStats({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('@${user.username}', style: TextStyle(color: Colors.grey[600])),
          user.bio.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(user.bio),
                )
              : SizedBox.shrink(),
          SizedBox(height: 8),
          Row(
            children: [
              Clickable(
                child: Text('${user.followers.length} Followers'),
                onTap: () => goToUsersList(context, user.id, 'Followers'),
              ),
              SizedBox(width: 16),
              Clickable(
                child: Text('${user.following.length} Following'),
                onTap: () => goToUsersList(context, user.id, 'Following'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


