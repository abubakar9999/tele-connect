import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hypos_tele_connect/themes/app_theme_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:hypos_tele_connect/logIn.dart';
import 'package:hypos_tele_connect/service/api_service.dart';
import 'hive/hive.dart';

void main() async{
  await Hive.initFlutter();
  await Boxes.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: defaultTheme,
      home: const LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String ip;

  const HomeScreen({super.key, required this.ip});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PhoneState status = PhoneState.nothing();
  bool isStreamSet = false;

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    return switch (status) {
      PermissionStatus.denied || PermissionStatus.restricted || PermissionStatus.limited || PermissionStatus.permanentlyDenied => false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };
  }

  @override
  void initState() {
    super.initState();
    requestPermission().then((isGranted) {
      if (isGranted) {
        WidgetsBinding.instance.addObserver(this);
        if (Platform.isAndroid) setStream();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Phone permission is required."),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      setStream();
    }
  }

  void setStream() {
    if (isStreamSet) return; // Prevent multiple listeners
    isStreamSet = true;

    PhoneState.stream.listen((event) async {
      setState(() {
        status = event;
      });

      if (status.number != null) {
        if (status.status == PhoneStateStatus.CALL_INCOMING || status.status == PhoneStateStatus.CALL_STARTED) {
          await ApiService().putnumber(status.number!, widget.ip).then((value) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text("Number Send to Hypos"),
              ),
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hypos Tele-Connect',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height/10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Connected with: ",style: TextStyle(color: Colors.white, ),),
                Text(widget.ip, style:  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),)
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Status of call',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            if (status.status == PhoneStateStatus.CALL_INCOMING || status.status == PhoneStateStatus.CALL_STARTED)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 250,
                  height: 48,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), color:  const Color(0xff6F5A80) , borderRadius: const BorderRadius.all(Radius.circular(20))),
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Number: ${status.number}',
                        style: const TextStyle( color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

           SizedBox(height: size.height/15,),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: COLOR_Grey),
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   FittedBox(
                    child: Icon(getIcons(), size: 80, color: getColor()),
                  ),
                ],
              ),
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     var data = await ApiService().putnumbers("01756074621", widget.ip);
            //     print(data);
            //   },
            //   child: const Text("Send"),
            // )
            const SizedBox(
              height: 200,
            ),
            const Spacer(),
            const Text("V-20240908",style: TextStyle(color: Colors.white),),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData getIcons() {
    return switch (status.status) {
      PhoneStateStatus.NOTHING => Icons.clear,
      PhoneStateStatus.CALL_INCOMING => Icons.add_call,
      PhoneStateStatus.CALL_STARTED => Icons.call,
      PhoneStateStatus.CALL_ENDED => Icons.call_end,
    };
  }

  Color getColor() {
    return switch (status.status) {
      PhoneStateStatus.NOTHING || PhoneStateStatus.CALL_ENDED => Colors.red,
      PhoneStateStatus.CALL_INCOMING => Colors.green,
      PhoneStateStatus.CALL_STARTED => Colors.orange,
    };
  }
}
