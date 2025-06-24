// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/user_model.dart';
// import './tutor_availability_view.dart';
// import './qualifications_view.dart';
// import '../../viewmodels/tutor_viewmodel.dart';
// import '../review/review_list_view.dart';

// class TutorView extends StatelessWidget {
//   final UserModel user;

//   const TutorView({Key? key, required this.user}) : super(key: key);

//   // Mock data for upcoming sessions with online avatar URLs
//   final List<Map<String, dynamic>> upcomingSessions = const [
//     {
//       'title': 'Object Oriented Programming',
//       'subtitle': 'Computer Programming',
//       'date': 'Thu 2 Dec 09:00 AM to 11:30 AM',
//       'language': 'EN',
//       'student': 'Marie Lemoine',
//       'price': 48.11,
//       'avatarUrl': 'https://api.dicebear.com/7.x/avataaars/png?seed=Marie',
//       'timeLeft': '00:10:15',
//     },
//   ];

//   // Mock data for booking requests with online avatar URLs
//   final List<Map<String, dynamic>> bookingRequests = const [
//     {
//       'title': 'Object Oriented Programming',
//       'subtitle': 'Computer Programming',
//       'date': 'Thu 9 Dec 09:00 AM to 09:30 AM',
//       'language': 'EN',
//       'student': 'Gloria Aguirre',
//       'avatarUrl': 'https://api.dicebear.com/7.x/avataaars/png?seed=Gloria',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Text(
//             'Manage Your Activities',
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue.shade800,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Divider(color: Colors.blue.shade300, thickness: 3, endIndent: 200),
//           const SizedBox(height: 20),

//           // Upcoming Sessions Section
//           Text(
//             'Upcoming Sessions',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...upcomingSessions
//               .map((session) => _sessionCard(context, session)),

//           const SizedBox(height: 30),

//           // Booking Requests Section
//           Text(
//             'Booking Requests',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...bookingRequests
//               .map((request) => _bookingRequestCard(context, request)),

//           const SizedBox(height: 30),

//           // Dashboard Tiles
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20,
//             childAspectRatio: 1,
//             children: [
//               _dashboardTile(
//                 icon: Icons.calendar_today,
//                 label: 'Availability',
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => TutorAvailabilityView(userId: user.uid),
//                   ),
//                 ),
//               ),
//               _dashboardTile(
//                 icon: Icons.school,
//                 label: 'Qualifications',
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ChangeNotifierProvider(
//                       create: (_) => TutorViewModel(),
//                       child: QualificationsView(uid: user.uid),
//                     ),
//                   ),
//                 ),
//               ),
//               _dashboardTile(
//                 icon: Icons.reviews,
//                 label: 'View Reviews',
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ReviewListView(
//                       tutorId: user.uid,
//                       tutorName: user.name,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sessionCard(BuildContext context, Map<String, dynamic> session) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title and language tag
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     session['title'],
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     session['language'],
//                     style: TextStyle(
//                       color: Colors.blue.shade800,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               session['subtitle'],
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//             const SizedBox(height: 12),

//             // Date and student info
//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                 const SizedBox(width: 6),
//                 Text(
//                   session['date'],
//                   style: TextStyle(color: Colors.grey.shade800),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(session['avatarUrl']),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   session['student'],
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Footer with countdown and price
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.timer, size: 16, color: Colors.blue),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Start in: ${session['timeLeft']}',
//                       style: const TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   '\$${session['price'].toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bookingRequestCard(BuildContext context, Map<String, dynamic> request) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title and language tag
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     request['title'],
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     request['language'],
//                     style: TextStyle(
//                       color: Colors.blue.shade800,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               request['subtitle'],
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//             const SizedBox(height: 12),

//             // Date and student info
//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                 const SizedBox(width: 6),
//                 Text(
//                   request['date'],
//                   style: TextStyle(color: Colors.grey.shade800),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(request['avatarUrl']),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   request['student'],
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Action buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // Handle reject
//                   },
//                   child: const Text(
//                     'Reject',
//                     style: TextStyle(color: Colors.redAccent),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle confirm
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                   ),
//                   child: const Text('Confirm'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dashboardTile({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.25),
//               blurRadius: 10,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 42, color: Colors.white),
//             const SizedBox(height: 14),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/user_model.dart';
import './tutor_availability_view.dart';
import './qualifications_view.dart';
import '../../viewmodels/tutor_viewmodel.dart';
import '../review/review_list_view.dart';
import '../booking/booking_list_view.dart';

class TutorView extends StatefulWidget {
  final UserModel user;

  const TutorView({Key? key, required this.user}) : super(key: key);

  @override
  State<TutorView> createState() => _TutorViewState();
}

class _TutorViewState extends State<TutorView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock events for calendar (you can replace with real data)
  final Map<DateTime, List<String>> _events = {
    DateTime.now().add(const Duration(days: 2)): ['Science Class', 'Math Tutoring'],
    DateTime.now().add(const Duration(days: 5)): ['Physics Workshop'],
    DateTime.now().add(const Duration(days: -1)): ['Review Session'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introductory Sentence for Teachers
              const Text(
                'Manage your teaching activities and track your schedule effortlessly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1976D2),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.blue.shade300.withOpacity(0.5), thickness: 3, endIndent: 200),
              const SizedBox(height: 20),

              // Quick Actions Section (Restored Functionalities)
              Text(
                'Your Teaching Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                  shadows: [
                    Shadow(
                      color: Colors.blue.shade200,
                      blurRadius: 3,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Access tools to organize your schedule and enhance student learning.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                children: [
                  _dashboardTile(
                    icon: Icons.calendar_today,
                    label: 'Availability',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TutorAvailabilityView(userId: widget.user.uid),
                      ),
                    ),
                    gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  _dashboardTile(
                    icon: Icons.school,
                    label: 'Qualifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => TutorViewModel(),
                          child: QualificationsView(uid: widget.user.uid),
                        ),
                      ),
                    ),
                    gradientColors: [Colors.cyan.shade400, Colors.cyan.shade700],
                  ),
                  _dashboardTile(
                    icon: Icons.reviews,
                    label: 'View Reviews',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewListView(
                          tutorId: widget.user.uid,
                          tutorName: widget.user.name,
                        ),
                      ),
                    ),
                    gradientColors: [Colors.indigo.shade400, Colors.indigo.shade700],
                  ),
                  _dashboardTile(
                    icon: Icons.book,
                    label: 'Bookings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TutorBookingListView(tutorId: widget.user.uid),
                      ),
                    ),
                    gradientColors: [Colors.teal.shade400, Colors.teal.shade700],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Calendar Section
              Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                  shadows: [
                    Shadow(
                      color: Colors.blue.shade200,
                      blurRadius: 3,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Keep track of your upcoming sessions and events.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              _calendarCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
              SizedBox(width: 8),
              Text(
                'Your Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red.shade600),
              selectedDecoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade300,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blue.shade800,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Colors.blue.shade600,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedDay != null)
            ..._getEventsForDay(_selectedDay!).map(
              (event) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: Colors.blue.shade800, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      event,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: Colors.white),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
