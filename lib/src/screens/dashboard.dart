import 'package:flutter/material.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';
import 'package:gym_app_flutter/src/tabs/profile.dart';
import 'package:gym_app_flutter/src/screens/create_workout.dart';
import 'package:intl/intl.dart';
import 'package:gym_app_flutter/src/screens/workout_details.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Workouts'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WorkoutsTab(apiService: apiService),
            ProfileTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateWorkoutScreen(apiService: apiService),
              ),
            );
            if (result == true) {
              // Refresh the workouts list if a new workout was created
              // final workoutsTabState =
              //     (DefaultTabController.of(context).contents[0] as WorkoutsTab)
              //         .createState() as _WorkoutsTabState;
              // workoutsTabState.getWorkouts();
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class WorkoutsTab extends StatefulWidget {
  final ApiService apiService;

  const WorkoutsTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _WorkoutsTabState createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  List<WorkoutDto>? _workouts;
  final Map<String, String> _workoutTypeMap = {
    'Gym': 'GYM',
    'Cardio': 'CARDIO',
    'Yoga': 'YOGA',
    'Sport': 'SPORT',
    'Other': 'OTHER',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkouts();
    });
  }

  void getWorkouts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    if (token != null) {
      try {
        final workouts = await widget.apiService.getAllWorkouts(token);
        setState(() {
          _workouts = workouts;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching workouts: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy - HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.token != null && _workouts == null) {
          getWorkouts();
        }

        if (_workouts == null) {
          return Center(child: CircularProgressIndicator());
        } else if (_workouts!.isEmpty) {
          return Center(child: Text('No workouts found'));
        } else {
          return ListView.separated(
            itemCount: _workouts!.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              WorkoutDto workout = _workouts![index];
              UserWorkoutResponseDto user =
                  workout.users[0]; // Assuming the first user for simplicity

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailsScreen(
                        workoutId: workout.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.profilePic != null
                                  ? NetworkImage(user.profilePic!.url)
                                  : AssetImage('assets/icon/icon.png')
                                      as ImageProvider,
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Chip(
                              label: Text(user.username),
                              backgroundColor: Colors.grey[200],
                            ),
                            Spacer(),
                            Text(
                              _workoutTypeMap[workout.type] ?? workout.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_formatDateTime(workout.startTime)} - ${_formatDateTime(workout.endTime)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          workout.notes ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 10),
                        _buildMediaPreview(workout.media),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMediaPreview(List<MediaClass> media) {
    if (media.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              media[index].url,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
