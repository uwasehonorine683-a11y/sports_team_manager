//UWASE HONORINE
//2401000620
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/team_model.dart';
import '../services/team_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

import 'player_screen.dart';
import 'match_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamService _teamService = TeamService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _sportController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not select image: $e')));
    }
  }

  Future<void> _createTeam() async {
    final user = _authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _sportController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team name and sport are required.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final teamId = DateTime.now().millisecondsSinceEpoch.toString();

      String logoUrl = '';

      if (_selectedImage != null) {
        logoUrl = await _storageService.uploadImage(
          folder: 'teams',
          userId: user.uid,
          imageFile: _selectedImage!,
        );
      }

      final team = TeamModel(
        id: teamId,
        ownerId: user.uid,
        name: _nameController.text.trim(),
        sport: _sportController.text.trim(),
        city: _cityController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl,
      );

      await _teamService.createTeam(team);

      _nameController.clear();
      _sportController.clear();
      _cityController.clear();
      _descriptionController.clear();

      setState(() {
        _selectedImage = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create team: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteTeam(TeamModel team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Team'),
          content: Text('Are you sure you want to delete "${team.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _teamService.deleteTeam(team.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete team: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in first.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _sportController,
              decoration: const InputDecoration(
                labelText: 'Sport',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Choose Team Logo'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _createTeam,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Team'),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<TeamModel>>(
                stream: _teamService.getTeams(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final teams = snapshot.data ?? [];

                  if (teams.isEmpty) {
                    return const Center(child: Text('No teams yet.'));
                  }

                  return ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: team.logoUrl.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(team.logoUrl),
                                )
                              : const CircleAvatar(child: Icon(Icons.groups)),
                          title: Text(team.name),
                          subtitle: Text('${team.sport} • ${team.city}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'players') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlayerScreen(team: team),
                                  ),
                                );
                              }

                              if (value == 'matches') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MatchScreen(team: team),
                                  ),
                                );
                              }

                              if (value == 'delete') {
                                _deleteTeam(team);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'players',
                                child: Text('Players'),
                              ),
                              PopupMenuItem(
                                value: 'matches',
                                child: Text('Matches'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
