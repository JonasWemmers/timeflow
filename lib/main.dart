import 'package:flutter/cupertino.dart';

void main() => runApp(const TimeFlowApp());

class TimeFlowApp extends StatelessWidget {
  const TimeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Time Flow'),
        ),
        child: Center(
          child: Text('Welcome to the Time Flow App!'),
        ),
      ),
    );
  }
}
