import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final ApiService apiService;

  const CreateWorkoutScreen({Key? key, required this.apiService})
      : super(key: key);

  @override
  _CreateWorkoutScreenState createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Gym'; // This should match one of the keys in _workoutTypeMap
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  String? _notes;
  List<File> _selectedImages = [];

  // Mapping between user-friendly names and API values
  final Map<String, String> _workoutTypeMap = {
    'Gym': 'GYM',
    'Cardio': 'CARDIO',
    'Yoga': 'YOGA',
    'Sport': 'SPORT',
    'Other': 'OTHER',
  };

  List<String> get _workoutTypes => _workoutTypeMap.keys.toList();

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Workout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Workout Type',
                border: OutlineInputBorder(),
              ),
              items: _workoutTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _type = newValue;
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            _buildDateTimePicker(
              label: 'Start Time',
              dateTime: _startTime,
              onChanged: (dateTime) => setState(() => _startTime = dateTime),
            ),
            SizedBox(height: 16.0),
            _buildDateTimePicker(
              label: 'End Time',
              dateTime: _endTime,
              onChanged: (dateTime) => setState(() => _endTime = dateTime),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _notes = value,
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Add Images'),
            ),
            SizedBox(height: 16.0),
            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Image.file(_selectedImages[index],
                              height: 100, width: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Create Workout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(dateTime),
          );
          if (pickedTime != null) {
            onChanged(DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ));
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateTime.toString().split('.')[0]),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      if (token != null) {
        try {
          final workout = CreateWorkoutDto(
            type: _workoutTypeMap[_type]!, // Use the mapped API value
            startTime: _startTime,
            endTime: _endTime,
            notes: _notes,
          );
          await widget.apiService.createWorkout(
            token,
            workout,
            _selectedImages,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Workout created successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating workout: $error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }
}
