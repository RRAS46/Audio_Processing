import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatefulWidget {
  final bool isSuccess;
  final String message;
  Map<String, dynamic> resultMap;

  ResultPage({
    Key? key,
    required this.isSuccess,
    required this.message,
    required this.resultMap,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // Function to format the date
  String formatDate(DateTime dateTime, {String format = 'dd/MM/yyyy'}) {
    final DateFormat dateFormat = DateFormat(format);
    return dateFormat.format(dateTime);
  }

  Color percentageToColor(double percentage) {
    // Map the percentage from 0-100 to a color gradient from red to green
    int red = (255 * (1 - percentage / 100)).toInt();
    int green = (255 * (percentage / 100)).toInt();
    return Color.fromRGBO(red, green, 0, 1); // Full red to full green
  }

  @override
  Widget build(BuildContext context) {
    print(widget.resultMap['shazam_results']);
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Show the result icon (success or failure)
                Icon(
                  widget.isSuccess ? Icons.check_circle : Icons.error,
                  color: widget.isSuccess ? Colors.green : Colors.red,
                  size: 100.0,
                ),
                SizedBox(height: 20),

                // Display the result message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isSuccess ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Display ID (if available) in a special card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      if (_isNotEmpty(widget.resultMap['id']))
                        Card(
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Text(
                              '#${widget.resultMap['id'].toString()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Spacer(),
                      if (_isNotEmpty(widget.resultMap['created_at']))
                        ...[
                          Column(
                            children: [
                              Text(
                                'Created At:',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isSuccess ? Colors.green : Colors.red,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                formatDate(DateTime.parse(widget.resultMap['created_at'])),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],

                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Display 'Created At' if available and formatted

                Divider(),
                // Display 'is_ai' and 'ircam_percentage' as per the request
                if (_isNotEmpty(widget.resultMap['is_ai']) && _isNotEmpty(widget.resultMap['ircam_percentage']) && (widget.resultMap['ircam_percentage'] > 0.0)) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left card with 'is_ai'
                      if (_isNotEmpty(widget.resultMap['is_ai']))
                        Card(
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'AI Status:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.resultMap['is_ai'] == true ? 'True' : 'False',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: widget.resultMap['is_ai'] == true ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Right card with 'ircam_percentage' and title 'Percentage'
                      if (_isNotEmpty(widget.resultMap['ircam_percentage']))
                        Card(
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Confidence:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '${widget.resultMap['ircam_percentage']}%',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: percentageToColor(widget.resultMap['ircam_percentage']),
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],

                // Display Annotations only if non-empty
                if (_isNotEmpty(widget.resultMap['annotations'])) ...[
                  Text(
                    'Annotations:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._buildAnnotationCards(widget.resultMap['annotations']),
                  SizedBox(height: 20),
                ],
                // Display other Result Details only if non-empty
                if (_isNotEmpty(widget.resultMap['shazam_results']) && (widget.resultMap['is_ai'] == false)) ...[
                  Divider(),

                  Text(
                    'Shazam Results:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildShazamResultsWidget(widget.resultMap['shazam_results']),
                  SizedBox(height: 20),
                ],

                SizedBox(height: 30),
                DownloadDataButton(resultMap: widget.resultMap),

                SizedBox(height: 30),
                // Buttons to retry or go back to the previous page
                Container(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isSuccess) {
                        Navigator.pop(context); // Go back to the previous screen
                      } else {
                        Navigator.pop(context); // Go back to the initial screen
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: widget.isSuccess ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      widget.isSuccess ? 'Go Back' : 'Retry',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to check if the value is not empty or null
  bool _isNotEmpty(dynamic value) {
    if (value == null) return false;
    if (value is List && value.isEmpty) return false;
    if (value is Map && value.isEmpty) return false;
    if (value is String && value.isEmpty) return false;
    return true;
  }

  // Helper function to format values for display
  String formatValue(String key, dynamic value) {
    if (key == "annotations" && value is List) {
      return "Annotations list is shown above.";
    } else if (key == "annotations" && value is Map) {
      return "Annotations data is listed above.";
    } else if (value is Map) {
      return "Map: ${value.isEmpty ? 'No Data' : 'Contains data'}";
    } else if (value is List) {
      return "List: ${value.isEmpty ? 'No items' : 'Contains ${value.length} items'}";
    } else if (value == null) {
      return "No Data";
    } else if (value is bool) {
      return value ? "True" : "False";
    } else {
      return value.toString();
    }
  }

  // Helper function to build annotation details as beautiful cards
  List<Widget> _buildAnnotationCards(dynamic annotations) {
    List<Widget> annotationWidgets = [];

    if (annotations is List) {
      for (var annotation in annotations) {
        annotationWidgets.add(
          Card(
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annotation Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildAnnotationItem("Player ID", annotation["playerid"]),
                  _buildAnnotationItem("Type", annotation["type"]),
                  _buildAnnotationItem("Timestamp", annotation["timestamp"]),
                ],
              ),
            ),
          ),
        );
      }
    }
    return annotationWidgets;
  }

  // Helper function to build individual annotation items
  Widget _buildAnnotationItem(String title, String? value) {
    if (value == null || value.isEmpty) {
      return SizedBox.shrink(); // Return an empty widget if there's no data
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No Data',
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build shazam results details as beautiful cards
  List<Widget> _buildShazamResults(dynamic shazamResults) {
    List<Widget> resultWidgets = [];

    if (shazamResults is List) {
      for (var result in shazamResults) {
        resultWidgets.add(
          Card(
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shazam Result:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildAnnotationItem("Shazam ID", result["shazam_id"]),
                  _buildAnnotationItem("Confidence", result["confidence"]),
                  _buildAnnotationItem("Timestamp", result["timestamp"]),
                ],
              ),
            ),
          ),
        );
      }
    }
    return resultWidgets;
  }


  Widget buildShazamResultsWidget(Map<String, dynamic> resultMap) {
    // Extract the Shazam results from widget.resultMap
    var shazamData = resultMap;

    // Check if 'shazam_results' exists and is not null
    if (shazamData == null) {
      return Center(child: Text("No Shazam results found."));
    }

    // Extract relevant data from the JSON
    var artists = shazamData['artists'];
    var title = shazamData['sections']?.firstWhere((section) => section['metadata'] != null, orElse: () => null)?['metadata']?.firstWhere((item) => item['title'] == 'Album', orElse: () => null)?['text'] ?? 'Unknown Title';
    var artist = artists != null && artists.isNotEmpty ? artists[0]['adamid']?.toString() ?? 'Unknown Artist' : 'Unknown Artist';
    var album = shazamData['sections']?.firstWhere((section) => section['metadata'] != null, orElse: () => null)?['metadata']?.firstWhere((item) => item['title'] == 'Album', orElse: () => null)?['text'] ?? 'Unknown Album';
    var coverArtUrl = shazamData['sections']?.firstWhere((section) => section['metapages'] != null, orElse: () => null)?['metapages']?.firstWhere((item) => item['image'] != null, orElse: () => null)?['image'] ?? '';
    var albumImageUrl = coverArtUrl; // Assuming the cover art and album image URL are the same
    var shareUrl = shazamData['relatedtracksurl'] ?? ''; // Use the related tracks URL as the share URL (or a fallback if needed)
    var providers = []; // The current response doesn't include providers, so leaving it empty for now.

    // Check if the necessary URLs and data exist before building the widget
    if (coverArtUrl.isEmpty || albumImageUrl.isEmpty) {
      return Center(child: Text("Missing album art or cover images."));
    }

    // Building the widget
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track Title & Artist Name
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: coverArtUrl.isNotEmpty ? NetworkImage(coverArtUrl) : null,
                  radius: 30,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      artist,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Album Image
            if (albumImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  albumImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),

            // Track Details (Album, Released, etc.)
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Album: $album',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Label: Warner Records', // Assuming static label here
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Released: 2023', // Assuming static release year
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Share Button
            ElevatedButton.icon(
              onPressed: () {
                if (shareUrl.isNotEmpty) {
                  _launchURL(shareUrl);
                }
              },
              icon: Icon(Icons.share),
              label: Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 16),

            // Music Streaming Providers (empty for now as the data doesn't include them)
            if (providers.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: providers.map<Widget>((provider) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: provider['images'] != null
                          ? Image.network(
                        provider['images']['default'] ?? '',
                        width: 40,
                        height: 40,
                      )
                          : Container(), // fallback for missing images
                      onPressed: () {
                        var providerUrl = provider['actions']?[0]['uri'];
                        if (providerUrl != null) {
                          _launchURL(providerUrl);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}



class DownloadDataButton extends StatelessWidget {
  final Map<String, dynamic> resultMap;

  DownloadDataButton({required this.resultMap});
  // Function to request storage permission on Android
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.request();
      if (!status.isGranted) {
        // If permission is not granted, show a message and return
        return;
      }
    }
  }

  // Function to save the data as a JSON file
  Future<void> _downloadData(BuildContext context) async {
    try {
      // Request permission to access storage
      await _requestPermission();

      // Convert resultMap to JSON string
      String jsonData = jsonEncode(resultMap);

      // Get the Downloads directory (platform-specific)
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        // For Android, get the Downloads directory
        downloadsDirectory = await getExternalStorageDirectory();
        if (downloadsDirectory != null) {
          String downloadPath = '${downloadsDirectory.path}/Download/';
          Directory(downloadPath).createSync(); // Create directory if it doesn't exist
          String filePath = '$downloadPath/shazam_data.json';

          // Write the JSON data to the file
          File file = File(filePath);
          await file.writeAsString(jsonData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data saved to $filePath")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to access storage")),
          );
        }
      } else {
        // For iOS, save in the app's document directory (sandboxed)
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/shazam_data.json';

        File file = File(filePath);
        await file.writeAsString(jsonData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data saved to $filePath")),
        );
      }
    } catch (e) {
      // Handle any errors that may occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _downloadData(context),
      icon: Icon(Icons.download),
      label: Text('Download Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
