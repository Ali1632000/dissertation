import 'dart:convert';

import 'package:http/http.dart' as http;

class PostApi {
  Map<String, dynamic>? apiResponse;
  Future<void> fetchData(String? title) async {
    final String apiUrl = "https://squid-app-xr6ep.ondigitalocean.app/predict";
    final Map<String, String> requestBody = {
      "text": title!,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        apiResponse = jsonDecode(response.body);
      } else {
        // Handle error cases here
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}





// import 'dart:convert';

// import 'package:http/http.dart' as http;

// class PostApi {
//   static String url = 'https://squid-app-xr6ep.ondigitalocean.app/predict';
//   String? priority;
//   Future<String> Response(String title) async {
//     final headers = {'Content-Type': 'application/json'};

//     final body = json.encode({'text': title});

//     try {
//       final response = await http.post(
//         Uri.parse('https://squid-app-xr6ep.ondigitalocean.app/predict'),
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         // final decodedResponse = json.decode(response.body) as Map;
//         final decodedResponse = json.decode(response.body) as Map;

//         if (decodedResponse.containsKey('priority')) {
//           final priority = decodedResponse['priority'];
//           print('Priority: $priority');
//           return priority;
//         } else {
//           print('Priority not found in the response');
//           return 'Error: Priority not found in the response';
//         }
//       } else {
//         print('Server error: ${response.statusCode}');
//         return 'Error: Server error ${response.statusCode}';
//       }
//     } catch (e) {
//       print('Error making the POST request: $e');
//       return 'Error: $e';
//     }
//   }
// }
