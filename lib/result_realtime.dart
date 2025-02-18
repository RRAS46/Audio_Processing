import 'package:supabase/supabase.dart'; // Ensure you have this import
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonationScreen extends StatefulWidget {
  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // Your Supabase Client instance
  final _supabaseClient = Supabase.instance.client;

  // List to store the result items
  List<Map<String, dynamic>> _resultItems = [];

  // Supabase channel for listening to changes
  late RealtimeChannel channelResultItem;

  @override
  void initState() {
    super.initState();
    _listenToResultItemChanges();
  }

  @override
  void dispose() {
    // Unsubscribe from the channel when the widget is disposed
    channelResultItem.unsubscribe();
    super.dispose();
  }

  // Function to listen for changes in the 'result' table
  void _listenToResultItemChanges() {
    channelResultItem = _supabaseClient
        .channel('public:result') // Listening to the 'result' table in the 'public' schema
    // Listen for new result items (Insert)
        .onPostgresChanges(
      table: 'result',
      event: PostgresChangeEvent.insert,
      callback: (payload) {
        final newRecord = payload.newRecord;

        if (newRecord.isNotEmpty) {
          setState(() {
            // Check if the result item already exists in the list
            final exists = _resultItems.any((item) => item['id'] == newRecord['id']);

            if (!exists) {
              _resultItems.insert(0, newRecord); // Add the new result item to the top
            }
          });
        }else{
          print("Nothing new");
        }
      },
    )
    // Listen for deleted result items (Delete)
        .onPostgresChanges(
      table: 'result',
      event: PostgresChangeEvent.delete,
      callback: (payload) {
        final deletedRecord = payload.oldRecord;

        if (deletedRecord.isNotEmpty) {
          setState(() {
            // Remove the result item with the matching id from the list
            _resultItems.removeWhere((item) => item['id'] == deletedRecord['id']);
          });
        }
      },
    )
    // Listen for updated result items (Update)
        .onPostgresChanges(
      table: 'result',
      event: PostgresChangeEvent.update,
      callback: (payload) {
        final updatedRecord = payload.newRecord;

        if (updatedRecord.isNotEmpty) {
          setState(() {
            // Find the index of the existing item in the list
            final index = _resultItems.indexWhere((item) => item['id'] == updatedRecord['id']);

            if (index != -1) {
              // Update the existing item with the new data
              _resultItems[index] = updatedRecord;
            }
          });
        }
      },
    )
        .subscribe(); // Subscribe to listen to the changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Results'),
      ),
      body: Container(
        color: Colors.green,
        child: ListView.builder(
          itemCount: _resultItems.length,
          itemBuilder: (context, index) {
            final resultItem = _resultItems[index];

            // Display the result items in a list
            return Container(
              color: Colors.blue,
              child: ListTile(
                title: Text('Result ID: ${resultItem['id']}'),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Annotations: ${resultItem['annotations']?? 'None'}'),
                    Text('Shazam Results: ${resultItem['shazam_results']?? 'None'}'),
                    Text('Is AI: ${resultItem['is_ai']?? 'None'}'),
                    Text('IRCAM Percentage: ${resultItem['ircam_percentage']?? 'None'}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
