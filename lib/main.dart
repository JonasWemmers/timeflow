import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core importieren

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialisieren
  runApp(const TimeFlowApp());
}

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
          child: Text('Welcome to Time Flow!'),
        ),
      ),
    );
  }
}
