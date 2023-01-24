import 'package:flutter/material.dart';
import 'package:opentrivia/models/category.dart';
import 'package:opentrivia/models/question.dart';
import 'package:opentrivia/ui/pages/quiz_finished.dart';
import 'package:html_unescape/html_unescape.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final Category? category;
  final String? Difficulty;

  const QuizPage(
      {Key? key, required this.questions, this.category, this.Difficulty})
      : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TextStyle _questionStyle = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);

  int _currentIndex = 0;
  bool select = true;
  final Map<int, dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Question question = widget.questions[_currentIndex];
    final List<dynamic> options = question.incorrectAnswers!;
    if (!options.contains(question.correctAnswer)) {
      options.add(question.correctAnswer);
      options.shuffle();
    }

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(widget.category!.name),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Text("${_currentIndex + 1}",
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        HtmlUnescape()
                            .convert(widget.questions[_currentIndex].question!),
                        softWrap: true,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ...options.map((option) => RadioListTile(
                            title: Text(
                              HtmlUnescape().convert("$option"),
                              style: MediaQuery.of(context).size.width > 800
                                  ? TextStyle(fontSize: 30.0)
                                  : null,
                            ),
                            groupValue: _answers[_currentIndex],
                            value: option,
                            onChanged: (dynamic value) {
                              setState(() {
                                _answers[_currentIndex] = option;
                              });
                            },
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: MediaQuery.of(context).size.width > 800
                            ? const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 64.0)
                            : null,
                      ),
                      child: Text(
                        _currentIndex == (widget.questions.length - 1)
                            ? "Submit"
                            : "Next",
                        style: MediaQuery.of(context).size.width > 800
                            ? TextStyle(fontSize: 30.0)
                            : null,
                      ),
                      onPressed: () {
                        if (_answers[_currentIndex] != question.correctAnswer &&
                            widget.Difficulty == "hard") {}
                        _nextSubmit();
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _nextSubmit() {
    if (_answers[_currentIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You must select an answer to continue."),
      ));
      return;
    }
    if (_currentIndex < (widget.questions.length - 1)) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QuizFinishedPage(
              questions: widget.questions, answers: _answers)));
    }
  }
}
