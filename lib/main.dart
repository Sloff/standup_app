import 'package:flutter/material.dart';
import 'package:standup_app/src/views/standup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final textTheme = theme.textTheme;

    return MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          appBar: AppBar(title: const Text('Standup App')),
          body: Row(children: [
            Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  ListTile(
                    leading: Icon(Icons.view_agenda),
                    title: Text('Standup'),
                    selected: true,
                    // selected: _selectedDestination == 0,
                    // onTap: () => selectDestination(0),
                  ),
                ],
              ),
            ),
            const Expanded(child: StandupPage())
          ]),
        ));
  }
}
