import 'dart:io';
import 'package:audio_processing/drawer_model.dart';
import 'package:audio_processing/main.dart';
import 'package:audio_processing/screens/result_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart';





class ShazamioModePage extends StatefulWidget {
  @override
  _ShazamioModePageState createState() => _ShazamioModePageState();
}

class _ShazamioModePageState extends State<ShazamioModePage> {

  // Your Supabase Client instance

  // List to store the result items
  List<Map<String, dynamic>> _resultItems = [];

  // Supabase channel for listening to changes
  late RealtimeChannel channelResultItem;


  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoadingAudio = false;
  bool _isUploading = false;
  bool _isProcessing=false;

  File? _audioFile;

  String _audioFileName = '';
  String _statusMessage = '';


  @override
  void initState() {
    super.initState();
    _requestPermission();
    _listenToResultItemChanges();
  }

  @override
  void dispose() {
    // Unsubscribe from the channel when the widget is disposed
    channelResultItem.unsubscribe();
    super.dispose();
  }
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.request();
      if (!status.isGranted) {
        // If permission is not granted, show a message and return
        return;
      }
    }
  }
  void _listenToResultItemChanges() {
    channelResultItem = supabase
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
              _isProcessing=false;
              _audioFile=null;
              _audioFileName='';
              Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(isSuccess: true, message: '',resultMap: newRecord,),));
              setState(() {

              });
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


  // Function to sanitize the file name before uploading
  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\.-]'), '_') // Replace invalid characters with '_'
        .replaceAll(' ', '_') // Replace spaces with '_'
        .replaceAll(RegExp(r'_{2,}'), '_') // Replace multiple underscores with one
        .replaceAll(RegExp(r'\.{2,}'), '.') // Replace multiple dots with one
        .replaceAll(RegExp(r'^\.|\.$'), '') // Remove leading/trailing dots
        .toLowerCase(); // Optionally make it lowercase
  }

  // Function to pick and load the audio file
  Future<File?> loadAudioFile() async {
    setState(() {
      _isLoadingAudio = true;
      _statusMessage = 'Selecting audio file...';
    });

    // Pick an audio file
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      File file = File(result.files.single.path!);
      String originalFileName = result.files.single.name;
      String sanitizedFileName = sanitizeFileName(originalFileName);

      setState(() {
        _audioFileName = sanitizedFileName;
        _statusMessage = 'Audio file selected: $sanitizedFileName';
      });
      _isLoadingAudio=false;
      return file; // Return the selected file
    } else {
      setState(() {
        _statusMessage = 'File picking canceled.';
      });
      _isLoadingAudio=false;

      return null; // Return null if no file is picked
    }
  }

// Function to upload the audio file to Supabase
  Future<void> uploadAudioFile(File file,String name,String dateformat) async {
    setState(() {
      _statusMessage = 'Uploading audio file...';
      print(_statusMessage);
    });

    try {
      // Upload the audio file to the bucket
      final response = await supabase.storage
          .from('raw') // Bucket name
          .upload('${name}/${dateformat}/${_audioFileName}', file); // Path in the bucket


    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }

    setState(() {
      _isLoadingAudio = false;
    });
  }


// Function to upload the JSON file to Supabase

  Future<void> insertIntoTable(String timestampz) async {
    setState(() {
      _statusMessage = 'Inserting data into audio...';
      print(_statusMessage);
    });
    final data = {
      'uuid' : Uuid().v4(),
      'audio_name': _audioFileName,
      'annotations_name' : "",
      'command': AudioProcessingMode.shazam.value,
      'created_by_uuid': supabase.auth.currentUser!.id,
      'created_at': timestampz, // Add a UTC timestamp
    };
    try {
      // Insert the data into the specified table
      final response = await supabase.from("audio").insert(data);

      if (response != null) {
        setState(() {
          _statusMessage = 'Data successfully inserted into audio!';
        });
      } else {
        setState(() {
          _statusMessage = 'Error inserting data into audio: ${response}';
        });
      }

      print(_statusMessage);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
      print('Error inserting data into audio: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: !_isProcessing ? CustomDrawer(onItemTapped: (p0) {

      },) : null,
      appBar:  !_isProcessing ? AppBar(title: Text('Shazam')) : null,
      body: Center(
        child: _isProcessing ? ProcessingIndicatorWidget() : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Stylish Upload Audio Button
              if(_audioFile == null)...[
                Container(
                  width: MediaQuery.of(context).size.width/1.1,
                  height: MediaQuery.of(context).size.height * .1,
                  child: ElevatedButton(
                    onPressed: _isLoadingAudio ? null : () async{
                      _audioFile= await loadAudioFile();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blue, // Button color
                      foregroundColor: Colors.white, // Text color
                      elevation: 4,
                    ),
                    child: _isLoadingAudio
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'Upload Audio',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                )
              ]else...[
                Container(

                  width: MediaQuery.of(context).size.width/1.1,
                  height: MediaQuery.of(context).size.height * .1,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width/1.5,
                          child: Text("${_audioFileName}",overflow: TextOverflow.ellipsis,)
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: (){
                          _audioFileName="";
                          _audioFile=null;
                          setState(() {

                          });
                        },
                        icon: Icon(Icons.close,color: Colors.grey.shade300,),
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.black26.withOpacity(0.15))),

                      )
                    ],
                  ),
                )
              ],

              SizedBox(height: 20),


              SizedBox(height: 20),



              ElevatedButton(
                onPressed: _audioFileName.isEmpty  ? null : (){
                  setState(() {
                    _isUploading=true;
                    print(_statusMessage);

                  });
                  final tempName=supabase.auth.currentUser!.userMetadata!['username'] ?? "User${Uuid().v4()}";

                  // ISO 8601 format (timestampz) with 24-hour clock (for your DB)
                  initializeTimeZones();

                  // Get current time in UTC timezone
                  final now = tz.TZDateTime.now(tz.UTC);

                  // Format Timestampz (with timezone)
                  String timestampz = now.toIso8601String();

                  // Format Date in custom format: yyyy_MM_dd-HH_mm_ss
                  String dateFormat = DateFormat('yyyy_MM_dd-HH_mm_ss').format(now);

                  print('Timestampz: $timestampz');
                  print('Date Format: $dateFormat');
                  uploadAudioFile(_audioFile!,tempName,dateFormat);
                  insertIntoTable(timestampz);
                  setState(() {
                    _isUploading=false;
                    _isProcessing=true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.green, // Button color for JSON upload
                  foregroundColor: Colors.white, // Text color
                  elevation: 4,
                ),
                child: _isUploading ? CircularProgressIndicator(): Text(
                  'Send',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProcessingIndicatorWidget extends StatelessWidget {
  final String message;

  const ProcessingIndicatorWidget({Key? key, this.message = "Processing..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Slightly transparent background
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ], // Subtle shadow for floating effect
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator with custom size
            Container(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(

                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 6, // Thicker stroke for visibility
                backgroundColor: Colors.grey.shade200, // Light background for the spinner
              ),
            ),
            SizedBox(height: 16),  // Space between spinner and message
            Text(
              message,
              style: TextStyle(
                color: Colors.black,  // Text color
                fontSize: 22,
                fontWeight: FontWeight.w600, // Slightly less bold for elegance
              ),
              textAlign: TextAlign.center, // Center align the text
            ),
          ],
        ),
      ),
    );
  }
}
