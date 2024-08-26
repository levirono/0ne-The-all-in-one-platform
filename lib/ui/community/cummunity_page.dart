import 'package:flutter/material.dart';
import 'package:one/services/auth.dart';
import 'package:one/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:one/ui/community/community_details.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = await _authService.getCurrentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade800,
                Colors.blue.shade600,
                Colors.green.shade500,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade800,
              Colors.blue.shade600,
              Colors.green.shade500,
            ],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.streamCommunities(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No communities found', style: TextStyle(color: Colors.white)));
            }

            var communities = snapshot.data!;

            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                var community = communities[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    title: Text(community['name']),
                    subtitle: Text('${community['memberCount']} members'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityDetailPage(communityId: community['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCommunity,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple.shade800,
      ),
    );
  }

  void _createNewCommunity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCommunityName = '';
        return AlertDialog(
          backgroundColor: Colors.purple.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Create New Community', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter community name',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            onChanged: (value) {
              newCommunityName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Create'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.purple.shade800,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                if (newCommunityName.isNotEmpty && currentUser != null) {
                  await _firestoreService.createCommunity(newCommunityName, currentUser!.uid);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}