import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ApiResponseScreen extends StatefulWidget {
  String? title;
  ApiResponseScreen({this.title});

  @override
  _ApiResponseScreenState createState() => _ApiResponseScreenState();
}

class _ApiResponseScreenState extends State<ApiResponseScreen> {
  late Future<Map<String, dynamic>> apiResponse;

  @override
  void initState() {
    super.initState();
    apiResponse = fetchData(widget.title);
  }

  Future<Map<String, dynamic>> fetchData(String? title) async {
    final String apiUrl = "https://29c3-39-43-144-115.ngrok-free.app/predict";
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
        return jsonDecode(response.body);
      } else {
        // Handle error cases here
        print("Error: ${response.statusCode}");
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Response Display'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: apiResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            Map<String, dynamic> data = snapshot.data!;
            return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Text(
                  data['priority'],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority: ${data['priority']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Steps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (data['steps'] as List<dynamic>).map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('- $step'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ]);
          }
        },
      ),
    );
  }
}
