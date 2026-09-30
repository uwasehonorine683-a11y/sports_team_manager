// UWASE HONORINE
// 2401000620

import 'package:flutter/material.dart';

import '../models/match_model.dart';
import '../models/team_model.dart';
import '../services/match_service.dart';

class MatchScreen extends StatefulWidget {
  final TeamModel team;

  const MatchScreen({super.key, required this.team});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final MatchService _matchService = MatchService();

  final _opponentController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _createMatch() async {
    if (_opponentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opponent name is required.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final match = MatchModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: widget.team.id,
        opponent: _opponentController.text.trim(),
        location: _locationController.text.trim(),
        matchDate: _selectedDate,
        teamScore: 0,
        opponentScore: 0,
        status: 'Scheduled',
      );

      await _matchService.createMatch(match);

      _opponentController.clear();
      _locationController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create match: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      await _matchService.deleteMatch(matchId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete match: $e')));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.team.name} Matches')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: _opponentController,
              decoration: const InputDecoration(
                labelText: 'Opponent',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.groups),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Date: ${_formatDate(_selectedDate)}'),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: _loading ? null : _selectDate,
                  child: const Text('Choose Date'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _createMatch,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Match'),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<MatchModel>>(
                stream: _matchService.getMatches(widget.team.id),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final matches = snapshot.data ?? [];

                  if (matches.isEmpty) {
                    return const Center(child: Text('No matches yet.'));
                  }

                  return ListView.builder(
                    itemCount: matches.length,

                    itemBuilder: (context, index) {
                      final match = matches[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.sports_soccer),
                          ),

                          title: Text('vs ${match.opponent}'),

                          subtitle: Text(
                            '${match.location.isEmpty ? 'No location' : match.location}\n'
                            '${_formatDate(match.matchDate)}\n'
                            'Status: ${match.status}',
                          ),

                          isThreeLine: true,

                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete Match',

                            onPressed: () {
                              _deleteMatch(match.id);
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
    _opponentController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
