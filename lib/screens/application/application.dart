import 'package:flutter/material.dart';
import 'package:geo_mapper/screens/home/home.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff161616),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300,
              width: 300,
              margin: EdgeInsets.only(right: 100),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'GeoMapper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Visualize geological features with ease!',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                SizedBox(height: 50),
                Container(
                  width: 350,
                  height: 48,
                  decoration: BoxDecoration(color: Color(0xff42a552)),
                  child: TextButton(
                    onPressed: () {
                      // Navigate to the map screen
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => Home()));
                    },
                    child: Text(
                      'Start Mapping',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
