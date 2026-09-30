//UWASE HONORINE
//2401000620

import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../models/team_model.dart';
import '../services/player_service.dart';

class PlayerScreen extends StatefulWidget {
  final TeamModel team;

  const PlayerScreen({super.key, required this.team});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerService _playerService = PlayerService();

  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = false;

  Future<void> _addPlayer() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Player name is required.')));
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final playerId = DateTime.now().millisecondsSinceEpoch.toString();

      final player = PlayerModel(
        id: playerId,
        teamId: widget.team.id,
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        jerseyNumber: int.tryParse(_jerseyController.text.trim()) ?? 0,
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        phone: _phoneController.text.trim(),
      );

      await _playerService.createPlayer(player);

      _nameController.clear();
      _positionController.clear();
      _jerseyController.clear();
      _ageController.clear();
      _phoneController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add player: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deletePlayer(String playerId) async {
    try {
      await _playerService.deletePlayer(playerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete player: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.team.name} Players')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _jerseyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jersey Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _addPlayer,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Player'),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<PlayerModel>>(
                stream: _playerService.getPlayers(widget.team.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final players = snapshot.data ?? [];

                  if (players.isEmpty) {
                    return const Center(child: Text('No players yet.'));
                  }

                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(player.jerseyNumber.toString()),
                          ),
                          title: Text(player.name),
                          subtitle: Text(
                            '${player.position} • Age ${player.age}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deletePlayer(player.id);
                            },
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
    _positionController.dispose();
    _jerseyController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
