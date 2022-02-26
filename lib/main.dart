import 'package:e2/helpers/firebase_auth_helper.dart';
import 'package:e2/helpers/firebase_rtdb_helper.dart';
import 'package:e2/screens/count_screen.dart';
import 'package:e2/screens/dashboard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const MyApp(),
        'dashboard': (context) => const DashBoard(),
        'count_screen': (context) => const CountScreen(),
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordLoginController = TextEditingController();
  String email = "";
  String password = "";
  List userData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voting App"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton.extended(
              heroTag: null,
              label: const Text("Register"),
              icon: const Icon(Icons.person),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Center(
                      child: Text("Register User"),
                    ),
                    content: Form(
                      key: _registerFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              onSaved: (val) {
                                setState(() {
                                  email = val!;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text("Email"),
                                hintText: "Enter your email id",
                              ),
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              onSaved: (val) {
                                setState(() {
                                  password = val!;
                                });
                              },
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text("Password"),
                                hintText: "Enter your Password",
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    _emailController.clear();
                                    _passwordController.clear();
                                    setState(() {
                                      email = '';
                                      password = '';
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text("Register"),
                                  onPressed: () async {
                                    if (_registerFormKey.currentState!.validate()) {
                                      _registerFormKey.currentState!.save();

                                      try {
                                        User? user = await FirebaseAuthHelper.authHelper.registerUserWithEmailAndPassword(email, password);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Register Successfully\nEmail: ${user!.email}\nUID: ${user.uid}"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context, true);
                                      } on FirebaseAuthException catch (e) {
                                        switch (e.code) {
                                          case 'weak-password':
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Enter at least 6 character long password"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            Navigator.pop(context, true);
                                            break;
                                          case 'email-already-in-use':
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("This email id is already in use"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            Navigator.pop(context, true);
                                            break;
                                        }
                                      }

                                      _emailController.clear();
                                      _passwordController.clear();
                                      setState(() {
                                        email = '';
                                        password = '';
                                      });
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            FloatingActionButton.extended(
              heroTag: null,
              label: const Text("Login"),
              icon: const Icon(Icons.input),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Center(
                      child: Text("Login User"),
                    ),
                    content: Form(
                      key: _loginFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _emailLoginController,
                              onSaved: (val) {
                                setState(() {
                                  email = val!;
                                });
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text("Email"),
                                hintText: "Enter your email",
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _passwordLoginController,
                              obscureText: true,
                              onSaved: (val) {
                                setState(() {
                                  password = val!;
                                });
                              },
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text("Password"),
                                hintText: "Enter your Password",
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    _emailLoginController.clear();
                                    _passwordLoginController.clear();
                                    setState(() {
                                      email = '';
                                      password = '';
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text("Login"),
                                  onPressed: () async {
                                    if (_loginFormKey.currentState!.validate()) {
                                      _loginFormKey.currentState!.save();

                                      try {
                                        User? user = await FirebaseAuthHelper.authHelper.loginUserWithEmailAndPassword(email, password);
                                        DatabaseEvent event = await RTDBHelper.rtdbHelper.fetchUserData();
                                        var data = event.snapshot.value;
                                        if (data != null) {
                                          var users = event.snapshot.value as Map;
                                          userData.clear();
                                          users.forEach((key, value) {
                                            userData.add({"key": key, ...value});
                                          });
                                          List uid = [];
                                          uid.clear();
                                          for (var e in userData) {
                                            uid.add(e['key']);
                                          }

                                          for (var e in userData) {
                                            if (uid.contains(user!.uid) && e['isVoted'] == false) {
                                              Navigator.of(context).pushReplacementNamed(
                                                'dashboard',
                                                arguments: user,
                                              );
                                              break;
                                            } else if (uid.contains(user.uid) && e['isVoted'] == true) {
                                              Navigator.of(context).pushReplacementNamed('count_screen');
                                              break;
                                            } else if (!uid.contains(user.uid)) {
                                              await RTDBHelper.rtdbHelper.insertUser(user.uid, false);
                                              Navigator.of(context).pushReplacementNamed(
                                                'dashboard',
                                                arguments: user,
                                              );
                                              break;
                                            }
                                          }
                                        } else {
                                          await RTDBHelper.rtdbHelper.insertUser(user!.uid, false);
                                          Navigator.of(context).pushReplacementNamed(
                                            'dashboard',
                                            arguments: user,
                                          );
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Login Successfully\nEmail: ${user!.email}\nUID: ${user.uid}"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        switch (e.code) {
                                          case 'user-not-found':
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("User not found with this email id"),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                            break;
                                          case 'wrong-password':
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Invalid Credentials..."),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                            break;
                                        }
                                      }
                                      _emailLoginController.clear();
                                      _passwordLoginController.clear();
                                      setState(() {
                                        email = '';
                                        password = '';
                                      });
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            FloatingActionButton.extended(
              heroTag: null,
              label: const Text("Login with Google"),
              icon: const Icon(Icons.add),
              onPressed: () async {
                DatabaseEvent event = await RTDBHelper.rtdbHelper.fetchUserData();
                var data = event.snapshot.value;
                User? user = await FirebaseAuthHelper.authHelper.signInWithGoogle();

                if (data != null) {
                  userData.clear();
                  var users = event.snapshot.value as Map;
                  users.forEach((key, value) {
                    userData.add({"key": key, ...value});
                  });
                  List uid = [];
                  uid.clear();
                  for (var e in userData) {
                    uid.add(e['key']);
                  }

                  for (var e in userData) {
                    if (uid.contains(user!.uid) && e['isVoted'] == false) {
                      Navigator.of(context).pushReplacementNamed(
                        'dashboard',
                        arguments: user,
                      );
                      break;
                    } else if (uid.contains(user.uid) && e['isVoted'] == true) {
                      Navigator.of(context).pushReplacementNamed('count_screen');
                      break;
                    } else if (!uid.contains(user.uid)) {
                      await RTDBHelper.rtdbHelper.insertUser(user.uid, false);
                      Navigator.of(context).pushReplacementNamed(
                        'dashboard',
                        arguments: user,
                      );
                      break;
                    }
                  }
                } else {
                  await RTDBHelper.rtdbHelper.insertUser(user!.uid, false);
                  Navigator.of(context).pushReplacementNamed(
                    'dashboard',
                    arguments: user,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Login Successfully\nEMAIL: ${user!.email}\nUID: ${user.uid}"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
