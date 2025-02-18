import 'package:audio_processing/drawer_model.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(onItemTapped: (p0) {},),
      appBar: AppBar(
        title: const Text('Profile Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                },
                child: Container(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          // Wrap Expanded in a Container or use Flex directly in a parent widget.
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: const ProfileWidget(
                            imagePath: 'https://i.imgur.com/qV26MhU.png',
                            onClicked: null,
                            errorWidget: Icon(
                              Icons.person_outline,
                              size: 128,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Icon(
                              Icons.qr_code,
                              size: 20,
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onClicked;
  final Widget errorWidget;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.onClicked,
    required this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClicked,
      child: ClipOval(
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        ),
      ),
    );
  }
}
