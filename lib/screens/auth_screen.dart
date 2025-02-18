import 'package:audio_processing/screens/all_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController(); // For sign up only
  bool isSignUp = false; // Toggle between Sign Up and Sign In
  bool isLoading = false;
  String errorMessage = '';


  @override
  void initState() {
    super.initState();
    isLoggedIn();
  }

  Future<void> isLoggedIn() async {
    final supabaseClient = Supabase.instance.client;

    // Get the current session
    final session = supabaseClient.auth.currentSession;

    // Delay the navigation until the current frame is built
    if (session != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllModePage(),
          ),
        );
      });
    } else {
      // Handle case where no session exists (e.g. navigate to login screen)
      print("User is not logged in");
    }
  }

  // Email validation function
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> handleAuth() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final email = _emailController.text.trim();
      final username = _usernameController.text.trim();

      if (email.isEmpty || (isSignUp && username.isEmpty)) {
        setState(() {
          errorMessage = 'Please fill in all fields.';
          isLoading = false;
        });
        return;
      }

      if (!isValidEmail(email)) {
        setState(() {
          errorMessage = 'Please enter a valid email address.';
          isLoading = false;
        });
        return;
      }

      if (isSignUp) {
        // Check if the username already exists in the 'profiles' table

        final existingUserResponse = await supabase
            .from('profiles')
            .select('username')
            .eq('username', username); // Fetch a single row if exists

        // Check if the query returned an empty result
        if (existingUserResponse.isNotEmpty && existingUserResponse.length > 0) {
          // Username already exists
          setState(() {
            errorMessage = 'Username is already taken. Please choose another one.';
            isLoading = false;
          });
          return;
        }

        // Sign up user with username as metadata
        final signUpResponse = await supabase.auth.signUp(
          email: email,
          password: '111111', // Default password
          data: {
            'username': username, // Store username in user metadata
          },
        );

        if (signUpResponse.user != null) {
          // Insert the username into the 'profiles' table (linked to the user_id)
          await supabase.from('profiles').insert({
            'uuid': supabase.auth.currentUser!.id, // The user_id from Supabase
            'username': username,
            'email': email,
          });

          // Navigate to profile or home page after successful sign-up
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AllModePage(),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Sign-up failed. Please try again.';
          });
        }
      } else {
        // Sign in user
        final signInResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: '111111', // Default password
        );

        if (signInResponse.user != null) {
          // Fetch username from metadata
          final user = supabase.auth.currentUser;
          final fetchedUsername = user?.userMetadata?['username'] ?? 'Unknown';
          print('Username retrieved: $fetchedUsername');

          // Navigate to profile or home page after successful sign-in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AllModePage(),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Authentication failed. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Authentication failed. Please try again.';
        print(e);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? 'Sign Up' : 'Sign In'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView( // Wrap the content in a scroll view
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.of(context).size.height * .7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Username Field (only for Sign Up)
              if (isSignUp)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16),

              // Error Message
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleAuth,
                  child: isLoading
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(isSignUp ? 'Sign Up' : 'Sign In'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.blueAccent, // Set the button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Toggle Sign Up/Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSignUp
                        ? 'Already have an account?'
                        : 'Don’t have an account?',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignUp = !isSignUp;
                        errorMessage = ''; // Reset error message
                      });
                    },
                    child: Text(
                      isSignUp ? 'Sign In' : 'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}
