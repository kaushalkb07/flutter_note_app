import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> get _notesStream {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _showNoteModal({DocumentSnapshot<Map<String, dynamic>>? doc}) {
    final titleController = TextEditingController(
      text: doc?.data()?['title'] ?? '',
    );
    final contentController = TextEditingController(
      text: doc?.data()?['content'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doc == null ? 'Add Note' : 'Edit Note',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) return;

                      final now = DateTime.now();

                      if (doc == null) {
                        await _firestore.collection('notes').add({
                          'title': title,
                          'content': content,
                          'createdAt': now,
                          'userId': currentUser?.uid,
                        });
                      } else {
                        await _firestore.collection('notes').doc(doc.id).update(
                          {
                            'title': title,
                            'content': content,
                            'createdAt': now,
                          },
                        );
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteNote(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await _firestore.collection('notes').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Notes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.email ?? "User"} 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _notesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final notes = snapshot.data?.docs ?? [];

                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes yet.\nTap + to add your first note.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final doc = notes[index];
                      final data = doc.data();
                      final createdAt =
                          (data['createdAt'] as Timestamp).toDate();
                      final formattedDate = DateFormat(
                        'MMM dd, yyyy – hh:mm a',
                      ).format(createdAt);

                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(data['content'] ?? ''),
                              const SizedBox(height: 8),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () => _showNoteModal(doc: doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteNote(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => _showNoteModal(),
        icon: const Icon(Icons.add),
        label: const Text("New Note", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
