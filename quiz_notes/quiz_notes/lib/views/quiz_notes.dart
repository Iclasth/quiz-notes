import 'package:flutter/material.dart';
import 'package:quiz_notes/views/home/home_page.dart';

class QuizNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Notes',
      theme: ThemeData.dark(
      ),
      home: HomePage(title: 'Quiz Notes',)
    );
     
  }
}