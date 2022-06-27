import 'package:intl/intl.dart';

void main() {
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  print(dateFormat.format(DateTime.now()));
}
