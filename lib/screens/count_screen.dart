import 'package:e2/helpers/firebase_auth_helper.dart';
import 'package:e2/helpers/firebase_rtdb_helper.dart';
import 'package:flutter/material.dart';

class CountScreen extends StatefulWidget {
  const CountScreen({Key? key}) : super(key: key);

  @override
  _CountScreenState createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result Page"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () async {
              FirebaseAuthHelper.authHelper.logOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: RTDBHelper.rtdbHelper.stream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            Map res = snapshot.data.snapshot.value;

            List items = [];

            res.forEach(
              (key, value) {
                items.add({"key": key, ...value});
              },
            );
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      return Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 3,
                        child: ListTile(
                          leading: Text(items[i]["key"]),
                          trailing: Text(items[i]["count"].toString()),
                        ),
                      );
                    });

              case ConnectionState.done:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
