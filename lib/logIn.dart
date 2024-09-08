import 'dart:convert';

import 'package:http/http.dart';
import 'package:hypos_tele_connect/hive/hive.dart';
import 'package:hypos_tele_connect/main.dart';

import 'package:flutter/material.dart';
import 'package:hypos_tele_connect/service/api_service.dart';
import 'package:hypos_tele_connect/themes/app_theme_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    ipAdderss.text = Boxes.ipNumber.get('ipNumber') ?? "";
    setState(() {});
    super.initState();
  }

  bool isLoading = false;
  TextEditingController ipAdderss = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: screenSize.height * 0.08,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: const Color(0xff6F5A80), borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text("Hypos Tele-Connect", textAlign: TextAlign.center, style: _textTheme.titleLarge),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Instructions(
              children: [
                _buildInstruction("◉ Please connect to the same Wi-Fi as the master device."),
                _buildInstruction("◉ Please enter the correct IP address to match the master device's IP."),
              ],
            ),
            const SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "IP Address :",
                  style: _textTheme.titleMedium,
                )),
            const SizedBox(height: 10),
            TextField(
              controller: ipAdderss,
              onChanged: (value) {
                setState(() {});
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '192.168.10.123',
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.monitor),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      dynamic connection;
                      if (ipAdderss.text.isNotEmpty) {
                        debugPrint("*************${ipAdderss.text}");

                        try {
                          isLoading = true;
                          setState(() {});
                          Future.delayed(const Duration(seconds: 2));
                          Response? response = await ApiService().establishConnection(ipAdderss.text);
                          connection = jsonDecode(response.body);
                          // Handle the response here if needed
                        } catch (e) {
                          // Handle the error or log it
                          debugPrint("Error: $e");
                        } finally {
                          // Always set isLoading to false, whether success or failure
                          isLoading = false;
                          setState(() {});
                        }
                        if (connection['status'] == 'Success') {
                          await Boxes.ipNumber.put('ipNumber', ipAdderss.text);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                connection['ret_str'],
                                style: const TextStyle(color: Colors.white),
                              )));
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(ip: ipAdderss.text)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Failed to establish connection",
                                style: TextStyle(color: Colors.white),
                              )));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Please input ip address",
                              style: TextStyle(color: Colors.white),
                            )));
                      }
                    },
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) => ipAdderss.text.isEmpty ? Colors.grey : COLOR_PRIMARY)),
                    child: Text(
                      'Connect',
                      style: TextStyle(fontSize: 18, color: ipAdderss.text.isEmpty ? Colors.white.withOpacity(.5) : Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Row(
      children: [
        const Icon(
          Icons.info,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class Instructions extends StatelessWidget {
  final List<Widget> children;

  const Instructions({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
    );
  }
}
