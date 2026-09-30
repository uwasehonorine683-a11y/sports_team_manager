// UWASE HONORINE
// 2401000620

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'team_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in first.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Team Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .where('ownerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, teamSnapshot) {
          if (teamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (teamSnapshot.hasError) {
            return Center(
              child: Text('Error loading teams: ${teamSnapshot.error}'),
            );
          }
          final teams = teamSnapshot.data?.docs ?? [];
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('players')
                .where(
                  'teamId',
                  whereIn: teams.isEmpty
                      ? ['no-team']
                      : teams.map((team) => team.id).toList(),
                )
                .snapshots(),
            builder: (context, playerSnapshot) {
              if (playerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (playerSnapshot.hasError) {
                return Center(
                  child: Text('Error loading players: ${playerSnapshot.error}'),
                );
              }
              final players = playerSnapshot.data?.docs ?? [];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('matches')
                    .where(
                      'teamId',
                      whereIn: teams.isEmpty
                          ? ['no-team']
                          : teams.map((team) => team.id).toList(),
                    )
                    .snapshots(),
                builder: (context, matchSnapshot) {
                  if (matchSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (matchSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading matches: ${matchSnapshot.error}',
                      ),
                    );
                  }
                  final matches = matchSnapshot.data?.docs ?? [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manage your teams, players and matches.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _DashboardCard(
                                icon: Icons.groups,
                                title: 'Teams',
                                value: teams.length.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DashboardCard(
                                icon: Icons.people,
                                title: 'Players',
                                value: players.length.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DashboardCard(
                                icon: Icons.sports_soccer,
                                title: 'Matches',
                                value: matches.length.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DashboardCard(
                                icon: Icons.event,
                                title: 'Upcoming',
                                value: matches.length.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TeamScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.groups),
                            label: const Text(
                              'Manage Teams',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TeamScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text(
                              'Manage Players',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TeamScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.sports_soccer),
                            label: const Text(
                              'Manage Matches',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 38),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
