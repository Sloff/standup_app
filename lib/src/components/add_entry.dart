import 'package:flutter/material.dart';

import '/src/models/models.dart';

class AddEntry extends StatefulWidget {
  const AddEntry({Key? key}) : super(key: key);

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final _formKey = GlobalKey<FormState>();

  final _entryController = TextEditingController();
  final _dateController =
      TextEditingController(text: DateTime.now().toString().substring(0, 10));

  bool isValid = false;

  @override
  void dispose() {
    _entryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () {
        setState(() {
          isValid = _formKey.currentState!.validate();
        });
      },
      autovalidateMode: AutovalidateMode.always,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Expanded(
            flex: 20,
            child: TextFormField(
              controller: _entryController,
              decoration: const InputDecoration(hintText: 'Enter a new value'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a value';
                }
                return null;
              },
            )),
        const Spacer(),
        Expanded(
          flex: 4,
          child: TextFormField(
              readOnly: true,
              controller: _dateController,
              decoration: const InputDecoration(hintText: 'Date'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please insert a date';
                }
                return null;
              },
              onTap: () async {
                var date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(_dateController.text),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100));

                if (date == null) {
                  return;
                }

                _dateController.text = date.toString().substring(0, 10);
              }),
        ),
        const Spacer(),
        IconButton(
            onPressed: !isValid
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      Task newTask = Task(description: _entryController.text);
                      Data.addTask(
                          dateOfEntry: DateTime.parse(_dateController.text),
                          task: newTask);
                    }
                  },
            icon: const Icon(Icons.send))
      ]),
    );
  }
}
