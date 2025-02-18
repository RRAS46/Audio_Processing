import 'dart:convert';
import 'dart:io';

import 'package:audio_processing/icon__bussiness__card_icons.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage1 extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isSuccess;
  final String message;

  // Constructor to pass the data Map
  ResultPage1({
    required this.data,
    required this.isSuccess,
    required this.message,});

  @override
  State<ResultPage1> createState() => _ResultPage1State();
}

class _ResultPage1State extends State<ResultPage1> {
  Map<String, dynamic> data={};
  Map<String, dynamic> songDetails={};

  @override
  void initState(){
    super.initState();
    data=widget.data;
    print(data.toString());
    songDetails=processData(data);
    for(var songDetail in songDetails.keys){
      print(songDetail);
    }
  }










  Map<String, dynamic> processData(Map<String, dynamic> data) {
    // Extract the required keys from the input JSON
    Map<String, dynamic> shazamResults = data['shazam_results'] ?? {};
    List<dynamic> isAiList = data['is_ai'] ?? [];
    List<dynamic> ircamPercentageList = data['ircam_percentage'] ?? [];

    // Create a new JSON object to store the processed songs
    Map<String, dynamic> processedSongs = {};

    // Iterate over the songs in shazamResults
    int index = 0;
    shazamResults.forEach((key, value) {
      processedSongs[key] = {
        'details': value,
        'is_ai': index < isAiList.length ? isAiList[index] : null,
        'ircam_percentage': index < ircamPercentageList.length ? ircamPercentageList[index] : null,
      };
      index++;
    });

    return processedSongs;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),

      body: ListView(
        children: [
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

          SizedBox(
            height: 10,
          ),
          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 25),
            child: Text(
              'Shazamio Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height *( songDetails.isEmpty ? 0.0 : .6),
            child: ListView.builder(
              itemCount: songDetails.keys.length, // Ensure the correct number of items
              itemBuilder: (context, index) {
                // Extract the key and song details for the current index
                final songKey = songDetails.keys.toList()[index];
                print(songKey);
                final currentSong = songDetails[songKey];
                // print("Current Song Data: ${jsonEncode(currentSong)}");
                print(currentSong['is_ai']);
                print(currentSong['ircam_percentage']);
                // Pass the current song's details to the _buildSongDetails widget
                return currentSong['is_ai'] == true  ? _buildAISongDetails(songKey, currentSong) : _buildSongDetails(songKey,currentSong);
              },
              scrollDirection: Axis.horizontal, // Scroll horizontally if you want cards side by side
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(),
          ),
          SizedBox(
            height: 10,
          ),

          data['annotations'] == null ? Container() :_buildAnnotations(),
          data['speaker_diarization'] == null ? Container() : _buildSpeakerDiarization(),
        ],
      ),
    );
  }


  Widget _buildSongDetails(String titleSong,Map<String, dynamic> songDetails) {
    // Guard clause for null or invalid data
    if (songDetails.isEmpty) {
      return Center(
        child: Text(
          'No song details available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Extract nested fields safely
    final title = songDetails['details']['shazamio_result']?['track']?['title'] ?? 'Unknown';
    final artist = songDetails['details']['shazamio_result']?['track']?['subtitle'] ?? 'Unknown'; // Access subtitle as artist info
    final genre = songDetails['details']['shazamio_result']?['track']?['genres']?['primary'] ?? 'Unknown'; // Nested field for genre
    final albumCover = songDetails['details']['shazamio_result']?['track']?['images']?['coverart'] ?? '';
    final appleMusicUrl = songDetails['details']['shazamio_result']?['track']?['hub']?['actions']?.firstWhere(
          (action) => action['type'] == 'uri',
      orElse: () => null,
    )?['uri'];
    final spotifyUrl = songDetails['details']['shazamio_result']?['track']?['hub']['providers']?.firstWhere(
          (provider) => provider['type'] == 'SPOTIFY',
      orElse: () => null,
    )?['actions']?.firstWhere(
          (action) => action['type'] == 'uri',
      orElse: () => null,
    )?['uri'];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Rounded corners for the whole container
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10), // Spacing between the cards
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Spacer(),
                  Text(
                    '#$title', // Assuming titleSong is a number you want to show
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Song info
              Text('🎤 Artist: $artist', style: TextStyle(fontSize: 16, color: Colors.black54)),
              Text('🎸 Genre: $genre', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 12),

              // Album cover with fallback if unavailable
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Rounded corners for the album art
                  child: albumCover.isNotEmpty
                      ? Image.network(
                    albumCover,
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
                      : const Icon(
                    Icons.album,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Buttons for music services
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: appleMusicUrl != null
                        ? () {
                      _openUrl(appleMusicUrl);
                    }
                        : null,
                    icon:  Icon(Icon_Bussiness_Card.apple),
                    style: ElevatedButton.styleFrom(
                      iconSize: 30,
                      backgroundColor: Colors.black87, // Dark background for Apple Music button
                      foregroundColor: Colors.white, // White icon and text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: spotifyUrl != null
                        ? () {
                      _openUrl(spotifyUrl);
                    }
                        : null,
                    icon: const Icon(Icon_Bussiness_Card.spotify),
                    style: ElevatedButton.styleFrom(
                      iconSize: 30,
                      backgroundColor: Colors.black, // Spotify color
                      foregroundColor: Colors.green, // White icon and text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: spotifyUrl != null
                        ? () {
                      _openUrl(spotifyUrl);
                    }
                        : null,
                    icon: const Icon(Icon_Bussiness_Card.youtube),
                    style: ElevatedButton.styleFrom(
                      iconSize: 30,
                      backgroundColor: Colors.red, // Spotify color
                      foregroundColor: Colors.white, // White icon and text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.only(top: 10,bottom: 10, left: 11,right: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: spotifyUrl != null
                        ? () {
                      _openUrl(spotifyUrl);
                    }
                        : null,
                    icon: const Icon(Icon_Bussiness_Card.stumbleupon),
                    style: ElevatedButton.styleFrom(
                      iconSize: 30,
                      backgroundColor: Colors.blueAccent, // Spotify color
                      foregroundColor: Colors.white, // White icon and text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
  Widget _buildAISongDetails(String titleSong, Map<String, dynamic> aiSongDetails) {
    // Guard clause for null or invalid data
    if (aiSongDetails.isEmpty) {
      print('niaou');
      return Center(
        child: Text(
          'No AI song details available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Extract AI-related fields safely
    final isAi = aiSongDetails['is_ai'];
    final ircamPercentage = aiSongDetails['ircam_percentage'];

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,

      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAi ? 'AI Song' : 'Unknown Song',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAi ? 'AI' : 'Not AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAi ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '#$titleSong',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // AI and Confidence Info Section
              Row(
                children: [
                  Icon(Icons.whatshot, color: isAi ? Colors.green : Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Generated: ${isAi ? 'Yes' : 'No'}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${ircamPercentage.toStringAsFixed(2)}%',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Center Icon for Album
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.album,
                    size: 80,
                    color: isAi ? Colors.green : Colors.red,
                  ),
                ),
              ),

              // Optional Buttons or Additional Information Section

            ],
          ),
        ),
      ),
    );
  }

// Helper function to open a URL
  void _openUrl(String url) async {
    print('Attempting to launch: $url');

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch the URL: $url');
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error occurred while launching URL: $e');
    }
  }

  // Build annotations from Map
  Widget _buildAnnotations() {
    final annotations = data['annotations']; // Ensure this key exists in your data
    print("Annotations : $annotations");
    return annotations != null
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
                margin: EdgeInsets.only(bottom: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionTile(
            title: Text(
              'Annotations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            children: [
              // Header

              SizedBox(height: 12),

              // Check if annotations is a list and display them
              if (annotations is List && annotations.isNotEmpty)
                ...annotations.map((annotation) {
                  return annotation is Map
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 24,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Player ID: ${annotation['playerid'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Timestamp: ${annotation['timestamp'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Type: ${annotation['type'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Invalid data',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }).toList()
              else
                Center(
                  child: Text(
                    'No annotations available or invalid data',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
            ],
          ),
                ),
              ),
        )

        : Container();
  }

  // Build speaker diarization from Map
  Widget _buildSpeakerDiarization() {
    final speakerDiarization = data['speaker_diarization']; // Ensure this key exists in your data

    // Check if speakerDiarization is not null and is of type List or Map
    if (speakerDiarization == null) {
      return Container(); // If it's null, return an empty container
    }

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        margin: EdgeInsets.only(bottom: 20),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionTile(

            title: Text(
                'Speaker Diarization',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),

            children: [
              // Title
              // Check and render speaker diarization data
              if (speakerDiarization is List && speakerDiarization.isNotEmpty)
                ...speakerDiarization.map((speaker) {
                  return speaker is Map
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 24,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speaker: ${speaker['speaker'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Start: ${speaker['start'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'End: ${speaker['end'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Invalid speaker data',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }).toList()
              else if (speakerDiarization is Map && speakerDiarization.isNotEmpty)
                ...speakerDiarization.values.map((speaker) {
                  return speaker is Map
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 24,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speaker: ${speaker['speaker'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Start: ${speaker['start'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'End: ${speaker['end'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Invalid speaker data',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }).toList()
              else
                Center(
                  child: Text(
                    'No speaker diarization data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
