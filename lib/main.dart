import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mgeilydszmdggyaqbtuu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nZWlseWRzem1kZ2d5YXFidHV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NjQzNTcsImV4cCI6MjA5NjI0MDM1N30.RG63pJQv6K4zJk8VErGaXiLQj9GNUDeyqiHMebSDGFM',
  );

  runApp(const BridgeApp());
}
