import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rasid_test/Core/util/time_stamp_adapter.dart';
import 'package:rasid_test/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Hive.registerAdapter(TimestampAdapter());
  await Hive.initFlutter();
  runApp(const MyApp());
}
