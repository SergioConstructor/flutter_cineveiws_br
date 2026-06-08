import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../models/user_profile.dart';
import 'public_profile_screen.dart';

class FollowersScreen extends StatelessWidget {
  final String? userId;
  final int initialTab;

  const FollowersScreen({super.key, this.userId, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        final effectiveId = userId ??
            (ModalRoute.of(context)?.settings.arguments as String? ??
                socialProvider.currentUser?.id ??
                '');

        final user = socialProvider.getProfileById(effectiveId) ??
            socialProvider.currentUser;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Usuário não encontrado')),
          );
        }

        final followers = socialProvider.getFollowers(user.id);
        final following = socialProvider.getFollowing(user.id);

        return DefaultTabController(
          length: 2,
          initialIndex: initialTab,
          child: Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              bottom: TabBar(
                tabs: [
                  Tab(text: '${followers.length} Seguidores'),
                  Tab(text: '${following.length} Seguindo'),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            body: TabBarView(
              children: [
                _buildUserList(context, followers, socialProvider),
                _buildUserList(context, following, socialProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList(BuildContext context, List<UserProfile> users,
      SocialProvider socialProvider) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              'Ninguém aqui ainda.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.id == socialProvider.currentUser?.id;
        final isFollowing = socialProvider.isFollowing(user.id);

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(user.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.username,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          trailing: isCurrentUser
              ? null
              : OutlinedButton(
                  onPressed: () =>
                      socialProvider.toggleFollow(user.id),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        isFollowing ? Colors.white : Colors.black,
                    side: isFollowing
                        ? const BorderSide(color: Colors.white24)
                        : BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Seguindo' : 'Seguir',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
          onTap: isCurrentUser
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PublicProfileScreen(userId: user.id),
                    ),
                  );
                },
        );
      },
    );
  }
}
