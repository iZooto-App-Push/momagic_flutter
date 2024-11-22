import 'dart:collection';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:momagic_flutter/momagic_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
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
     Home({required this.title});
      @override
      _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
      static const platform = const MethodChannel("iZooto-flutter");
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
                    // iZooto.navigateToSettings();
                    print("Unsuscribe false");
                  },
              ),
          );
      }

      void initMethod() async {
         
          if (Platform.isIOS) {
              DATB.iOSInit(
              appId: "d7e40672e1d6bad8c3ef6ecb0291cf4ab8e11b87");       // for iOS
          }
          DATB.setSubscriberID("6575678");
         DATB.shared.onTokenReceived((token){
              print('Token >>  $token ');

         });
          DATB.shared.onNotificationReceived((payload) {        // Received payload Android/iOS
              print('PayLoad >>  $payload');
          });

          DATB.shared.onNotificationOpened((data) {     // DeepLink Android/iOS
              print('Data >>  $data');
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SecondRoute()));
          });

          DATB.shared.onWebView((landingUrl) {      //LandingURLDelegate Android/iOS
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
      PageTwo({required this.title});
      @override
      _PageTwoState createState() => new _PageTwoState();
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
  const SecondRoute();
    @override
    Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Second Page'),
            ),
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                print("Subscribe True");
              },
              child: const Text('Go back!'),
            ),
          ),
        );
    }
}