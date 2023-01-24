import 'dart:io';
import 'package:flutter/material.dart';
import 'package:opentrivia/models/category.dart';
import 'package:opentrivia/models/question.dart';
import 'package:opentrivia/resources/api_provider.dart';
import 'package:opentrivia/ui/pages/error.dart';
import 'package:opentrivia/ui/pages/quiz_page.dart';

class QuizOptionsDialog extends StatefulWidget {
  final Category? category;

  const QuizOptionsDialog({Key? key, this.category}) : super(key: key);

  @override
  _QuizOptionsDialogState createState() => _QuizOptionsDialogState();
}

class _QuizOptionsDialogState extends State<QuizOptionsDialog> {
  int? _noOfQuestions;
  String? _difficulty;
  String? _type;
  late bool processing;

  @override
  void initState() {
    super.initState();
    _noOfQuestions = 10;
    _type = "boolean";
    _difficulty = "easy";
    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Text(
              widget.category!.name,
              style: Theme.of(context).textTheme.headline6!.copyWith(),
            ),
          ),
          SizedBox(height: 10.0),
          Text("Select Difficulty"),
          SizedBox(height: 10.0),
          SizedBox(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 16.0,
              spacing: 16.0,
              children: <Widget>[
                SizedBox(width: 0.0),
                ActionChip(
                  label: Text("Easy"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _difficulty == "easy"
                      ? Colors.indigo
                      : Colors.grey.shade600,
                  onPressed: () => {
                    _selectNumberOfQuestions(5),
                    _selectDifficulty("easy"),
                    _selecttype("boolean"),
                  },
                ),
                ActionChip(
                  label: Text("Medium"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _difficulty == "medium"
                      ? Colors.indigo
                      : Colors.grey.shade600,
                  onPressed: () => {
                    _selectNumberOfQuestions(10),
                    _selectDifficulty("medium"),
                    _selecttype(null)
                  },
                ),
                ActionChip(
                  label: Text("Hard"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _difficulty == "hard"
                      ? Colors.indigo
                      : Colors.grey.shade600,
                  onPressed: () => {
                    _selectDifficulty("hard"),
                    _selectNumberOfQuestions(50),
                    _selecttype(null),
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            child: Text("Start Quiz"),
            onPressed: _startQuiz,
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  _selectNumberOfQuestions(int i) {
    setState(() {
      _noOfQuestions = i;
    });
  }

  _selectDifficulty(String? s) {
    setState(() {
      _difficulty = s;
    });
  }

  _selecttype(String? s) {
    setState(() {
      _type = s;
    });
  }

  void _startQuiz() async {
    setState(() {
      processing = true;
    });
    try {
      List<Question> questions = await getQuestions(
          widget.category!, _noOfQuestions, _difficulty, _type);
      Navigator.pop(context);
      if (questions.length < 1) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ErrorPage(
                  message:
                      "There are not enough questions in the category, with the options you selected.",
                )));
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => QuizPage(
                    questions: questions,
                    category: widget.category,
                  )));
    } on SocketException catch (_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ErrorPage(
                    message:
                        "Can't reach the servers, \n Please check your internet connection.",
                  )));
    } catch (e) {
      print(e.toString());
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ErrorPage(
                    message: "Unexpected error trying to connect to the API",
                  )));
    }
    setState(() {
      processing = false;
    });
  }
}
