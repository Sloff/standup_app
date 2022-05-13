import 'package:interact/interact.dart';

bool isRequired(String val) {
  if (val.isNotEmpty) {
    return true;
  }

  throw ValidationError('A description is required');
}
