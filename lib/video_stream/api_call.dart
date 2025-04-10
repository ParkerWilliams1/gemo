import 'dart:convert';
import 'package:http/http.dart' as http;

//Auth token we will use to generate a meeting and connect to it
String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIxMmUzZGIwZi0wZWYwLTQyMzMtODk2NC00YzJiZmY5ZDdkNzAiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTc0MzcwMzMzNSwiZXhwIjoxNzQ0MzA4MTM1fQ.Jkv48k1ZnRf6zB9dmUN2jBq3Ox3rHqY2rJ1fyQQRU1Y";

// API call to create meeting
Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token},
  );

//Destructuring the roomId from the response
  return json.decode(httpResponse.body)['roomId'];
}