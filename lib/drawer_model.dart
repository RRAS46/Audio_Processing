import 'package:audio_processing/screens/ai_detector_screen.dart';
import 'package:audio_processing/screens/all_screen.dart';
import 'package:audio_processing/screens/auth_screen.dart';
import 'package:audio_processing/screens/profile.dart';
import 'package:audio_processing/screens/shazamio_screen.dart';
import 'package:audio_processing/screens/speaker_diarization_screen.dart';
import 'package:audio_processing/screens/split_audio_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTapped; // Callback to handle menu item taps

  CustomDrawer({required this.onItemTapped});
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/avatar.png'), // Add your image here
                ),
                SizedBox(height: 10),
                Text(
                  supabase.auth.currentUser!.userMetadata!['username'] ?? "User",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  supabase.auth.currentUser!.email! ?? "user@example.com",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              onItemTapped(0); // Call the callback for Home
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllModePage(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              onItemTapped(0); // Call the callback for Home
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('All'),
            onTap: () {
              onItemTapped(1); // Call the callback for Profile
              Navigator.pop(context);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllModePage(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.splitscreen),
            title: Text('Split Audio'),
            onTap: () {
              onItemTapped(2); // Call the callback for Settings
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplitAudioModePage(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.keyboard_voice),
            title: Text('Speaker Diarization'),
            onTap: () {
              // Add your logout functionality here
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SpeakerDiarizationModePage(),));

            },
          ),
          ListTile(
            leading: Icon(Icons.surround_sound),
            title: Text('Shazamio'),
            onTap: () {
              // Add your logout functionality here
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShazamioModePage(),));
            },
          ),
          ListTile(
            leading: Icon(Icons.my_location),
            title: Text('Ai Detector'),
            onTap: () {
              // Add your logout functionality here
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AiDetectorModePage(),));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout,color: Colors.red,),  // You can choose any icon, like logout
            title: Text('Sign Out'),
            onTap: () async {
              // Sign out the user using Supabase
              final supabaseClient = Supabase.instance.client;
              await supabaseClient.auth.signOut();

              // After sign out, navigate to the login page or home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()), // Replace with your login page
              );
            },
          )


        ],
      ),
    );
  }
}
