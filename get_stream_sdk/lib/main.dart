import 'package:flutter/material.dart';
import 'package:get_stream_sdk/call_screen.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = StreamVideo(
    'mmhfdzb5evj2',
    user: User.regular(userId: 'Ulic_Qel-Droma', role: 'admin', name: 'John Doe'),
    userToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL1VsaWNfUWVsLURyb21hIiwidXNlcl9pZCI6IlVsaWNfUWVsLURyb21hIiwidmFsaWRpdHlfaW5fc2Vjb25kcyI6NjA0ODAwLCJpYXQiOjE3NDMwMzQ3NzMsImV4cCI6MTc0MzYzOTU3M30.Tfmtgi2vuxJLNryOrp7JsLwh6wOPHKFZ20txOnL2JOY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Call App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Video Call"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Create Call'),
          onPressed: () async {
            try {
              var call = StreamVideo.instance.makeCall(
                callType: StreamCallType.development(),
                id: 'v5dEhD1e4znT',
              );

              await call.getOrCreate();

              // Navigate to the CallScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(call: call),
                ),
              );
            } catch (e) {
              debugPrint('Error joining or creating call: $e');
              debugPrint(e.toString());
            }
          },
        ),
      ),
    );
  }
}