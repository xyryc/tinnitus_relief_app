import "package:flutter/material.dart";
    
    void main(){
    runApp(const MyApp());
    }

    class MyApp extends StatelessWidget{
    const MyApp({super.key});

      @override
      Widget build(BuildContext context){
      return MaterialApp(
        title: "Tinnitus Relief",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true
        ),
        home: const LoginScreen(),
      );
      }
    }

    class LoginScreen extends StatefulWidget {
      const LoginScreen({super.key});

      @override
      State<LoginScreen> createState() => _LoginScreenState();
    }

    class _LoginScreenState extends State<LoginScreen>{
      @override
      Widget build(BuildContext context){
        return Scaffold(
        backgroundColor: Colors.white,
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.music_note_outlined, size: 40, color: Colors.deepPurple,
                    )
                  ],
                ),
              )),
        );
      }
    }