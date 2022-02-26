import 'package:firebase_database/firebase_database.dart';

class RTDBHelper {
  RTDBHelper._();

  static final RTDBHelper rtdbHelper = RTDBHelper._();

  static final FirebaseDatabase database = FirebaseDatabase.instance;

  insertUser(String uid, bool isVoted) async {
    DatabaseReference ref = database.ref('voting');
    await ref.child("users").child(uid).set({"isVoted": isVoted});
  }

  updateUser(String uid, bool isVoted) async {
    DatabaseReference ref = database.ref('voting');
    await ref.child("users").child(uid).child("isVoted").set(isVoted);
  }

  Future<void> insert(String name) async {
    DatabaseReference ref = database.ref('voting');
    await ref.child("party").child(name).set({"count": 0});
  }

  fetchVoteCount(String name) async {
    DatabaseReference ref = database.ref('voting/party/$name/count/');
    DatabaseEvent event = await ref.once();
    return event;
  }

  Future<void> updateCount(String name, int i) async {
    await database.ref('voting/party/$name/').update({"count": i});
  }

  fetchUserData() async {
    DatabaseReference ref = database.ref('voting/users');
    DatabaseEvent event = await ref.once();
    return event;
  }

  Stream stream() {
    return database.ref('voting/party').onValue;
  }
}
