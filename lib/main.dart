import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:modernsocialapp/providers/user_provider.dart';
import 'package:modernsocialapp/resources/messaging_api.dart';
import 'package:modernsocialapp/responsive/mobile_screen_layout.dart';
import 'package:modernsocialapp/responsive/responsive_layout.dart';
import 'package:modernsocialapp/responsive/web_screen_layout.dart';
import 'package:modernsocialapp/screens/login_screen.dart';
import 'package:modernsocialapp/secrets.dart';
import 'package:modernsocialapp/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid? await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: Secrets.apiKey,
        appId: Secrets.appId,
        messagingSenderId: Secrets.messagingSenderId,
        projectId: Secrets.projectId,
        storageBucket: Secrets.storageBucket
    )
  ) : await Firebase.initializeApp();
  await MessagingApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ModernSocial',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasn't been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
