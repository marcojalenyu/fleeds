import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/features/profile/logic/profile_controller.dart';
import 'package:nota/features/post/logic/post_controller.dart';
import 'package:nota/widgets/main_scaffold.dart';
import 'package:nota/widgets/post_list.dart';
import 'package:nota/widgets/profile_btn.dart';
import 'package:nota/widgets/profile_pic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileController _profileController;
  final _postController = PostController();
  List<Post> _posts = [];
  List<Post> _likedPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ModalRoute.of(context)!.settings.arguments as User;
    _profileController = ProfileController(user);
    _fetchUserPosts(user.id);
    _fetchPostsLikedByUser(user.id);
  }

  void _fetchUserPosts(String userId) async {
    final posts = await _postController.fetchPostsByUser(userId);
    setState(() => _posts = posts);
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
    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _profileController,
            builder: (context, _) => Text('@${_profileController.user.username}'),
          ),
        ),
        body: AnimatedBuilder(
          animation: _profileController,
          builder: (context, _) {
            final user = _profileController.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileHeader(user: user),
                  SizedBox(height: 16),
                  _ProfileButtonRow(controller: _profileController),
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
                            _fetchUserPosts(_profileController.user.id);
                            _fetchPostsLikedByUser(_profileController.user.id);
                          },
                        ),
                        Center(child: Text('User Replies')),
                        PostList(
                          initialPosts: _likedPosts,
                          onPostChanged: (_) {
                            _fetchPostsLikedByUser(_profileController.user.id);
                            _fetchUserPosts(_profileController.user.id);
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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        controller.isOwnProfile
            ? ProfileBtn(
                label: 'Edit Profile',
                onPressed: () {},
              )
            : ProfileBtn(
                label: controller.isFollowing ? 'Unfollow' : 'Follow',
                isFollowing: controller.isFollowing,
                showHoverUnfollow: true,
                onPressed: controller.followUser,
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
              Text('${user.followers.length} Followers'),
              SizedBox(width: 16),
              Text('${user.following.length} Following'),
            ],
          ),
        ],
      ),
    );
  }
}