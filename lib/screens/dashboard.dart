import 'package:e2/helpers/firebase_auth_helper.dart';
import 'package:e2/helpers/firebase_rtdb_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String data = "";
  String radioVal = 'vote';
  int? j;

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text("DashBoard"),
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
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatefulBuilder(builder: (context, _setState) {
                          return Container(
                            padding: const EdgeInsets.only(
                              left: 125,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: items
                                  .map(
                                    (e) => RadioListTile(
                                        title: Text(e['key']),
                                        value: "${e['key']}",
                                        groupValue: radioVal,
                                        onChanged: (val) {
                                          _setState(() {
                                            radioVal = val.toString();
                                          });
                                        }),
                                  )
                                  .toList(),
                            ),
                          );
                        }),
                        ElevatedButton(
                          onPressed: () async {
                            await RTDBHelper.rtdbHelper.updateUser(args.uid, true);
                            DatabaseEvent event = await RTDBHelper.rtdbHelper.fetchVoteCount(radioVal);
                            j = event.snapshot.value as int;
                            RTDBHelper.rtdbHelper.updateCount(radioVal, j! + 1);
                            Navigator.of(context).pushReplacementNamed('count_screen');
                          },
                          child: const Text("Submit Vote"),
                        ),
                      ],
                    ),
                  ),
                );

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
