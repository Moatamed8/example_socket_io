import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Socket Io Example in Local Host'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Socket socket; //initalize the Socket.IO Client Object
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    initializeSocket(); //--> call the initializeSocket method in the initState of our app.
  }

  @override
  void dispose() {
    socket
        .disconnect(); // --> disconnects the Socket.IO client once the screen is disposed
    controller.dispose();
    super.dispose();
  }

  void initializeSocket() {
    socket = io("http://127.0.0.1:3000/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect(); //connect the Socket.IO Client to the Server

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    //listen for incoming messages from the Server.
    socket.on('message', (data) {
      print(data); //
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Socket connection: ${socket.connected}',
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (socket.connected) {
                      socket.disconnect();
                    } else {
                      socket.connect();
                    }
                  });
                },
                child: Text(socket.connected ? "Disconnect" : "Connect")),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: controller,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    socket.emit(
                      "message",
                      {
                        "id": socket.id,
                        "message": controller.text,
                        "username": "Moatamed",
                        "sentAt": DateTime.now()
                            .toLocal()
                            .toString()
                            .substring(0, 16),
                      },
                    );
                    controller.clear();
                  }
                },
                child: const Text("Send Message")),
          ],
        ),
      ),
    );
  }
}
