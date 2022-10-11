import 'package:flutter/material.dart';
import 'package:standup_app/src/components/add_entry.dart';
import 'package:watcher/watcher.dart';

import '/src/models/models.dart';
import '/src/utils/utils.dart' as utils;

class StandupPage extends StatefulWidget {
  const StandupPage({Key? key}) : super(key: key);

  @override
  State<StandupPage> createState() => _StandupPageState();
}

class _StandupPageState extends State<StandupPage> {
  bool dataFetched = false;
  StandupInfo? standupInfo;

  _StandupPageState() {
    _fetchData();

    Data.getConfigFileWatcher().events.listen((event) {
      if (event.type == ChangeType.MODIFY) {
        _fetchData();
      }
    });
  }

  _fetchData() {
    Data.getTasksForStandup().then((standupTasks) {
      setState(() {
        dataFetched = true;
        standupInfo = standupTasks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!dataFetched) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: ListView(children: [
            _buildHeading(
              utils.getRelativeDateHeading(standupInfo!.previousDayDate!),
            ),
            ..._buildTaskItemsFromList(standupInfo!.previousDay),
            _buildHeading("Today I'm working on"),
            ..._buildTaskItemsFromList(standupInfo!.today),
          ]),
        ),
        const AddEntry()
      ]),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(task.description));
  }
}

Widget _buildHeading(String text) {
  return Text(text, style: const TextStyle(fontSize: 28));
}

Iterable _buildTaskItemsFromList(List<Task> tasks) {
  if (tasks.isEmpty) {
    return [
      const ListTile(
        title: Text('Nothing yet...'),
        textColor: Colors.yellow,
      )
    ];
  }
  return tasks.map((task) => TaskItem(task: task));
}
