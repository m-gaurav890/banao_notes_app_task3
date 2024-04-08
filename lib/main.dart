import 'package:banao_notes_app_task3/screen/home.dart';
import 'package:banao_notes_app_task3/screen/login.dart';
import 'package:banao_notes_app_task3/services/login_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isLogin=false;

  getLoggedInState()async{
    await LocalDataSaver.getLogData().then((value){
      setState(() {
        isLogin=value.toString()=="null";
      });
    });

  }

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLogin ? const LoginScreen():const Home(),
    );
  }
}