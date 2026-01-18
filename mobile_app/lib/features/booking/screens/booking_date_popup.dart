import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class BookingDatePopup extends StatefulWidget {
  const BookingDatePopup({super.key});

  @override
  State<BookingDatePopup> createState() => _BookingDatePopupState();
}

class _BookingDatePopupState extends State<BookingDatePopup> {
  final DateTime _focusedDay = DateTime(2025, 4, 1); // Mocked start based on design image (April 2025)
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();

  // Mocking the months from the design (April 2025, May 2025)
  final List<DateTime> _months = [
    DateTime(2025, 4),
    DateTime(2025, 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background from design
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Title
          const Text(
            "Choose Booking Date",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Serif',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Year Navigation (Mocked for exact UI match)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios, color: AppConstants.primaryColor, size: 20),
                Text(
                  "${_focusedDay.year}", 
                  style: const TextStyle(color: AppConstants.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const Icon(Icons.arrow_forward_ios, color: AppConstants.primaryColor, size: 20),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _months.length,
              itemBuilder: (context, index) {
                return _buildMonthSection(_months[index]);
              },
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedDay);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Confirm", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOffset = DateTime(month.year, month.month, 1).weekday % 7;
    
    // Month Name
    final monthName = _getMonthName(month.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(
            monthName, 
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) return const SizedBox();
            
            final day = index - firstDayOffset + 1;
            final date = DateTime(month.year, month.month, day);
            final isSelected = _selectedDay != null && 
                               _selectedDay!.year == date.year && 
                               _selectedDay!.month == date.month && 
                               _selectedDay!.day == date.day;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDay = date;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryColor : const Color(0xFF2A2A2A),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1]; // "Mei" in design seems like Indonesian/Malay/Dutch, sticking to English "May" unless requested otherwise or "Mei" specifically desired. Design has "April" and "Mei". "Mei" is May.
  }
}
