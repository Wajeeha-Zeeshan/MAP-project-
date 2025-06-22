import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../tutor/tutor_detail_view.dart'; // Import your existing tutor detail view

class SubjectTutorsView extends StatelessWidget {
  final String subject;

  const SubjectTutorsView({super.key, required this.subject});

  final Map<String, String> subjectDescriptions = const {
    'Maths':
        'Learn mathematical concepts, problem-solving techniques, and logical reasoning skills.',
    'English':
        'Enhance your grammar, vocabulary, reading comprehension, and writing proficiency.',
    'Science':
        'Explore physics, chemistry, biology, and the scientific method to understand the world.',
    'Computer':
        'Dive into computing fundamentals, programming, and digital literacy.',
    'History':
        'Understand past events, civilizations, and the impact of historical change.',
  };

  @override
  Widget build(BuildContext context) {
    final description =
        subjectDescriptions[subject] ??
        'Explore this subject with our expert tutors.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tutors for $subject'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.lightBlue[50],
            child: Text(description, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('tutors')
                      .where('subjects', arrayContains: subject)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No tutors available for this subject.'),
                  );
                }

                final tutors = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final data = tutors[index].data() as Map<String, dynamic>;
                    final uid = data['uid'];

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text('Loading name...'),
                          );
                        }

                        final userData =
                            userSnapshot.data?.data() as Map<String, dynamic>?;
                        final tutorName = userData?['name'] ?? 'Unknown Tutor';

                        // Add name and email into the data before passing
                        final completeTutorData = {
                          ...data,
                          'name': tutorName,
                          'email': userData?['email'] ?? '',
                        };

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tutorName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Subjects: ${(data['subjects'] as List).join(', ')}',
                                          ),
                                          Text(
                                            'Qualification: ${data['qualification'] ?? 'N/A'}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => TutorDetailView(
                                                  tutor: completeTutorData,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4facfe,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Book Tutor'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
