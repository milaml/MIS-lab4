import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import '../models/event.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventData = prefs.getStringList('events') ?? [];
    setState(() {
      events = eventData.map((e) => Event.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      events.add(event);
    });
    prefs.setStringList('events', events.map((e) => json.encode(e.toJson())).toList());
  }

  void _addEvent() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              ElevatedButton(
                onPressed: () async {
                  selectedDate = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    selectedDate != null) {
                  _saveEvent(Event(
                    title: titleController.text,
                    dateTime: selectedDate!,
                    location: locationController.text,
                    latitude: 0.0, 
                    longitude: 0.0,
                  ));
                }
                Navigator.of(ctx).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('213021 Exam Schedule')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (ctx, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text(
                '${DateFormat.yMMMd().format(event.dateTime)} at ${event.location}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
      ),
    );
  }
}
