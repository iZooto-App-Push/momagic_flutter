// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:momagic_flutter/momagic_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'HomePage'),
      routes: {
        'pageTwo': (context) => PageTwo(title: 'Page Two'),
      },
    );
  }
}

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text(
          'HomePage',
          style: TextStyle(color: Colors.green, fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        autofocus: true,
        focusElevation: 5,
        child: const Icon(Icons.notifications),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SecondRoute()));
          // DATB.navigateToSettings();
        },
      ),
    );
  }

  void initMethod() async {
    if (Platform.isIOS) {
      DATB.iOSInit(
          appId: "d7e40672e1d6bad8c3ef6ecb0291cf4ab8e11b87"); // for iOS
    }

    DATB.androidInit();

    // DATB.androidInit(isDefaultWebView: true);
    
    DATB.promptForPushNotifications();

    //DATB.setSubscriberId("79057172");

    // DATB.setNotificationChannelName("channelName");

    // DATB.setSubscription(true);

    // AddEvent
    // Map<String, Object> eventValue = {};
    // eventValue['name'] = 'Alice';         
    // eventValue['age'] = 25;              
    // eventValue['isStudent'] = true;        
    // eventValue['skills'] = ['Dart', 'Flutter']; 
    // DATB.addEvent("eventName", eventValue);

    // Add Tag
    // List<String> topicName = ['Math', 'Science', 'History'];
    // DATB.addTag(topicName);

    // AddUserProperties
     DATB.addUserProperty("tuesday","2026-07-20 16:04:05");

    // Remove TAG
    // DATB.removeTag(topicName);

    // DATB.setDefaultNotificationBanner("setBanner");
    // DATB.setDefaultTemplate(PushTemplate.DEFAULT);
    // DATB.setNotificationSound("soundName");
    // DATB.setFirebaseAnalytics(true);
    
    DATB.shared.onTokenReceived((token) {
      print('Token >>  $token ');
    });

    DATB.shared.onNotificationReceived((payload) {
      print('PayLoad >>  $payload');
    });

    DATB.shared.onNotificationOpened((data) {
      print('DeepLink >>  $data');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SecondRoute()));
    });

    DATB.shared.onWebView((landingUrl) {
      print('Landing URL >>  $landingUrl');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SecondRoute()));
    });
  }
}

Future<dynamic> onPush(String name, Map<String, dynamic> payload) {
  return Future.value(true);
}

class PageTwo extends StatefulWidget {
  final String title;
  const PageTwo({super.key, required this.title});
  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('Page Two'),
      ),
      floatingActionButton: FloatingActionButton(
        autofocus: true,
        focusElevation: 5,
        child: const Icon(Icons.notifications),
        onPressed: () {

          // iZooto.setNewsHub();
        },
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            DATB.addUserProperty("mobile","abcd");

            Navigator.pop(context);
            // print("Subscribe True");
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
