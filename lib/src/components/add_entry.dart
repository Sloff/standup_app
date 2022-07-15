import 'package:flutter/material.dart';

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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Expanded(
            flex: 20,
            child: TextFormField(
              controller: _entryController,
              decoration: const InputDecoration(hintText: 'Enter a new value'),
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
                  return 'Please insert a value';
                }
                return null;
              },
              onTap: () async {
                var date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100));

                _dateController.text = date.toString().substring(0, 10);
              }),
        ),
        const Spacer(),
        IconButton(
            onPressed: _entryController.text.isEmpty
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Working')));
                    }
                  },
            icon: const Icon(Icons.send))
      ]),
    );
  }
}
