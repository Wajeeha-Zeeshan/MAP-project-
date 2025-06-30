import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/user_model.dart';
import '../tutor/tutor_list_view.dart';
import '../booking/students_booking_view.dart';
import '../tutor/subjects_tutors_view.dart';

class StudentView extends StatefulWidget {
  final UserModel user;

  const StudentView({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock events for calendar (you can replace with real data)
  final Map<DateTime, List<String>> _events = {
    DateTime.now().add(const Duration(days: 1)): ['Math Tutoring'],
    DateTime.now().add(const Duration(days: 3)): ['Science Review'],
    DateTime.now().add(const Duration(days: 5)): ['English Essay Due'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Animation
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'Courses for You',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
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
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade300],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Dashboard Tiles with Enhanced Styling
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: [
                  _dashboardTile(
                    icon: Icons.search,
                    label: 'Browse Tutors',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorListView()),
                    ),
                    gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  _dashboardTile(
                    icon: Icons.book,
                    label: 'View Bookings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StudentBookingListView()),
                    ),
                    gradientColors: [Colors.cyan.shade400, Colors.cyan.shade700],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Subjects Section with Updated List
              Text(
                'Subjects',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 12),
              Text(
                'Explore tutors by subject to enhance your learning.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _subjectChip(context, 'Math'),
                  _subjectChip(context, 'English'),
                  _subjectChip(context, 'Science'),
                  _subjectChip(context, 'Computer'),
                  _subjectChip(context, 'History'),
                ],
              ),
              const SizedBox(height: 30),

              // Calendar Section
              Text(
                'Your Schedule',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 12),
              Text(
                'Keep track of upcoming tutoring sessions and deadlines.',
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

  Widget _subjectChip(BuildContext context, String subject) {
    return ActionChip(
      label: Text(subject),
      backgroundColor: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(
        color: Colors.blue.shade800,
        fontWeight: FontWeight.w500,
      ),
      elevation: 2,
      shadowColor: Colors.blue.shade100,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectTutorsView(subject: subject),
          ),
        );
      },
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
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.white),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
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
            color: Colors.blue.shade100.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month, color: Color(0xFF1976D2)),
              SizedBox(width: 8),
              Text(
                'Upcoming Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1976D2),
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
}
