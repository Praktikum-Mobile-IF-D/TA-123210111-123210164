import 'package:flutter/material.dart';
import '../handler/database_handler.dart';
import '../model/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User>? user;

  @override
  void initState() {
    super.initState();
    user = fetchUser();
  }

  Future<User> fetchUser() async {
    DatabaseHandler dbHandler = DatabaseHandler();
    List<User> users = await dbHandler.retrieveUsers();
    return users.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            return Column(
              children: [
                Text('Username: ${snapshot.data!.username}'),
                Text('Password: ${snapshot.data!.password}'),
                  Image.network(snapshot.data!.image! as String),
              ],
            );
          }
        },
      ),
    );
  }
}