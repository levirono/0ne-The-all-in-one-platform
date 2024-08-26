import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:one/services/firestore_service.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;

  CommunityDetailPage({required this.communityId});

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  // ignore: unused_field
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<DocumentSnapshot> _communityStream;
  late Stream<QuerySnapshot> _notesStream;
  late Stream<QuerySnapshot> _membersStream;

  @override
  void initState() {
    super.initState();
    _communityStream = FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .snapshots();
    _notesStream = FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('shared_notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
    _membersStream = FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('members')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _communityStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return Text(snapshot.data!['name']);
          },
        ),
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
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _communityStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              bool isCreator = snapshot.data!['createdBy'] == _auth.currentUser!.uid;
              return isCreator
                  ? IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: _showAddMemberDialog,
                    )
                  : Container();
            },
          ),
        ],
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
        child: Column(
          children: [
            _buildMembersList(),
            Expanded(child: _buildNotesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple.shade800,
      ),
    );
  }

  Widget _buildMembersList() {
    return Container(
      height: 100,
      child: StreamBuilder<QuerySnapshot>(
        stream: _membersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var member = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Text(member['fullName'][0]),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member['fullName'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _notesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var note = snapshot.data!.docs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                title: Text(note['title']),
                subtitle: Text(
                  note['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditNoteDialog(note),
                ),
                onTap: () => _showNoteDetails(note),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(user['fullName']),
                      onTap: () {
                        _addMemberToCommunity(user.id, user['fullName']);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _addMemberToCommunity(String userId, String fullName) {
    FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('members')
        .doc(userId)
        .set({
      'fullName': fullName,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showAddNoteDialog() {
    String title = '';
    String content = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Content'),
                onChanged: (value) => content = value,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  _addNote(title, content);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addNote(String title, String content) {
    FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('shared_notes')
        .add({
      'title': title,
      'content': content,
      'createdBy': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _showEditNoteDialog(DocumentSnapshot note) {
    String title = note['title'];
    String content = note['content'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Title'),
                onChanged: (value) => title = value,
                controller: TextEditingController(text: title),
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Content'),
                onChanged: (value) => content = value,
                controller: TextEditingController(text: content),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  _updateNote(note.id, title, content);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateNote(String noteId, String title, String content) {
    FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('shared_notes')
        .doc(noteId)
        .update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showNoteDetails(DocumentSnapshot note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note['title']),
          content: Text(note['content']),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}