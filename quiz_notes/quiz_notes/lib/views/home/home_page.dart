import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:<Widget> [
            _buildTitle(),
          ],
        )
        ) ,
       
      
    );
  }
  Widget _buildTitle() => Text(
        "Quiz Notes",
        textAlign: TextAlign.center,
       );
}