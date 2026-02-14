import 'package:fleeds/features/components/profile/presentation/profile.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/features/screens/profile/logic/profile_controller.dart';
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
    _profileController!.addListener(() => setState(() {}));
    await _profileController!.fetchUserContent(_profileController!.userOnProfile!.id);
    setState(() => _loading = false);
  }

  void _refreshProfile() {
    if (_profileController != null) {
      _profileController!.postController.resetPagination();
      _profileController!.repliesController.resetPagination();
      _profileController!.likedController.resetPagination();
      _profileController!.fetchUserContent(_profileController!.userOnProfile!.id);
    } else {
      _initProfileController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileController?.dispose();
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

    final controller = _profileController!;

    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => SelectableText('@${controller.userOnProfile!.username}'),
          ),
        ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final user = controller.userOnProfile;
            return RefreshIndicator(
              onRefresh: () async => _refreshProfile(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ProfileHeader(user: user!),
                        const SizedBox(height: 16),
                        ProfileButtonRow(controller: controller),
                        ProfileStats(user: user),
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Replies'),
                            Tab(text: 'Likes'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        if (_tabController.index == 0) {
                          return PostList(
                            initialPosts: controller.userPosts,
                            onLoadMore: controller.loadMoreUserPosts,
                            onPostChanged: (_) => controller.fetchUserContent(user.id),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          );
                        } else if (_tabController.index == 1) {
                          return PostList(
                            initialPosts: controller.userReplies,
                            onLoadMore: controller.loadMoreUserReplies,
                            onPostChanged: (_) => controller.fetchUserContent(user.id),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          );
                        } else {
                          return PostList(
                            initialPosts: controller.likedPosts,
                            onLoadMore: controller.loadMoreLikedPosts,
                            onPostChanged: (_) => controller.fetchUserContent(user.id),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          );
                        }
                      },
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