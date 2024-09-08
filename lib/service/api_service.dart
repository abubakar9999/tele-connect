import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<http.Response> putnumber(String number, String ipAdderss) async {
    debugPrint("----------------http://$ipAdderss:2222/putnumber");
    final http.Response response = await http.post(
      Uri.parse("http://$ipAdderss:2222/putnumber"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "number": number,
      }),
    );
    return response;
  }

  Future<http.Response> establishConnection(String masterIpAddress) async {
    try {
      debugPrint("----------------http://$masterIpAddress:2222/checkip");
      final http.Response response = await http
          .post(
        Uri.parse("http://$masterIpAddress:2222/checkip"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "ipAddress": masterIpAddress,
        }),
      )
          .timeout(const Duration(seconds: 10));

      // Check if the response body contains 'status' and it's 'Success'
      if (jsonDecode(response.body)['status'] == 'Success') {
        return response;
      } else {
        debugPrint('Connection failed: ${response.body}');
        return http.Response(jsonEncode({'status': 'Failed'}), 200);  // or handle it in another way based on your use case
      }
    } catch (e) {
      // Handling timeout or any other exceptions
      debugPrint('Error establishing connection: $e');
      return http.Response(jsonEncode({'status': 'Failed'}), 500);
    }
  }

  // Future<String> putnumbers(String number, String ipAdderss) async {
  //   try {
  //     final http.Response res = await putnumber(number, ipAdderss);
  //     return jsonDecode(res.body.toString());
  //   } on Exception catch (e) {
  //     debugPrint('Repositories.addNumber() error: $e');
  //     return "error";
  //   }
  // }
}
