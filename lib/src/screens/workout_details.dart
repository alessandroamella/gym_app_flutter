import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final int workoutId;

  // apiService is required to fetch workout details
  final ApiService apiService = ApiService();

  WorkoutDetailsScreen({required this.workoutId});

  @override
  _WorkoutDetailsScreenState createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  WorkoutDto? _workout;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutDetails();
  }

  void _fetchWorkoutDetails() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    if (token != null) {
      try {
        final workout =
            await widget.apiService.getWorkout(token, widget.workoutId);
        setState(() {
          _workout = workout;
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching workout: $error')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime, {bool showDate = true}) {
    final DateFormat formatter =
        DateFormat(showDate ? 'MMM dd, yyyy - HH:mm' : 'HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workout == null
              ? const Center(child: Text('No workout details available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Workout Information'),
                        _buildWorkoutInfo(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Notes'),
                        _buildNotes(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Media'),
                        _buildMediaPreview(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Users Involved'),
                        _buildUserList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _workout!.type,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_formatDateTime(_workout!.startTime)} - ${_formatDateTime(_workout!.endTime, showDate: false)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Time: ${_formatDateTime(_workout!.startTime)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('End Time: ${_formatDateTime(_workout!.endTime)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Type: ${_workout!.type}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Created At: ${_formatDateTime(_workout!.createdAt)}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Updated At: ${_formatDateTime(_workout!.updatedAt)}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _workout!.notes ?? 'No notes available',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_workout!.media.isEmpty) {
      return const Text('No media available');
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _workout!.media.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                _workout!.media[index].url,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      children: _workout!.users.map((user) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profilePic != null
                  ? NetworkImage(user.profilePic!.url)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            ),
            title: Text(user.username),
            subtitle: Text('Workouts: ${user.workoutCount}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }
}
