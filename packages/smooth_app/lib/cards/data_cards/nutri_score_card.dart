import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class NutriScoreCard extends StatelessWidget {
  const NutriScoreCard({required this.score, Key? key}) : super(key: key);

  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: ROUNDED_BORDER_RADIUS,
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NutriScoreGrade('A', score == 'a'),
          _NutriScoreGrade('B', score == 'b'),
          _NutriScoreGrade('C', score == 'c'),
          _NutriScoreGrade('D', score == 'd'),
          _NutriScoreGrade('E', score == 'e'),
        ],
      ),
    );
  }
}

class _NutriScoreGrade extends StatelessWidget {
  const _NutriScoreGrade(this.grade, this.isHighlighted);

  final String grade;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: isHighlighted ? _getColor(grade) : Colors.transparent,
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: isHighlighted ? Colors.white : _getColor(grade),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
