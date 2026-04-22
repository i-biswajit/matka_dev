import 'package:flutter/material.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  // Static chart data for 30 days
  final List<Map<String, dynamic>> chartData = const [
    {
      "date": "04 Jan 2026",
      "day": "Sun",
      "numbers": ["470", "14", "770"]
    },
    {
      "date": "03 Jan 2026",
      "day": "Sat",
      "numbers": ["159", "55", "690"],
      "red": [true, true, true]
    },
    {
      "date": "02 Jan 2026",
      "day": "Fri",
      "numbers": ["238", "31", "344"]
    },
    {
      "date": "01 Jan 2026",
      "day": "Thu",
      "numbers": ["128", "14", "257"]
    },
    {
      "date": "31 Dec 2025",
      "day": "Wed",
      "numbers": ["358", "66", "457"],
      "red": [true, true, true]
    },
    {
      "date": "30 Dec 2025",
      "day": "Tue",
      "numbers": ["446", "43", "247"]
    },
    {
      "date": "29 Dec 2025",
      "day": "Mon",
      "numbers": ["169", "64", "789"]
    },
    {
      "date": "28 Dec 2025",
      "day": "Sun",
      "numbers": ["223", "78", "378"]
    },
    {
      "date": "27 Dec 2025",
      "day": "Sat",
      "numbers": ["160", "75", "500"]
    },
    {
      "date": "26 Dec 2025",
      "day": "Fri",
      "numbers": ["239", "48", "125"]
    },
    {
      "date": "25 Dec 2025",
      "day": "Thu",
      "numbers": ["112", "48", "558"]
    },
    {
      "date": "24 Dec 2025",
      "day": "Wed",
      "numbers": ["490", "31", "560"]
    },
    {
      "date": "23 Dec 2025",
      "day": "Tue",
      "numbers": ["569", "05", "168"],
      "red": [true, true, true]
    },
    {
      "date": "22 Dec 2025",
      "day": "Mon",
      "numbers": ["780", "56", "330"]
    },
    {
      "date": "21 Dec 2025",
      "day": "Sun",
      "numbers": ["457", "64", "789"]
    },
    {
      "date": "20 Dec 2025",
      "day": "Sat",
      "numbers": ["400", "46", "349"]
    },
    {
      "date": "19 Dec 2025",
      "day": "Fri",
      "numbers": ["269", "78", "170"]
    },
    {
      "date": "18 Dec 2025",
      "day": "Thu",
      "numbers": ["559", "94", "130"],
      "red": [true, true, true]
    },
    {
      "date": "17 Dec 2025",
      "day": "Wed",
      "numbers": ["238", "33", "444"]
    },
    {
      "date": "16 Dec 2025",
      "day": "Tue",
      "numbers": ["111", "22", "333"]
    },
    {
      "date": "15 Dec 2025",
      "day": "Mon",
      "numbers": ["490", "55", "560"]
    },
    {
      "date": "14 Dec 2025",
      "day": "Sun",
      "numbers": ["333", "44", "666"]
    },
    {
      "date": "13 Dec 2025",
      "day": "Sat",
      "numbers": ["123", "45", "678"]
    },
    {
      "date": "12 Dec 2025",
      "day": "Fri",
      "numbers": ["234", "56", "789"]
    },
    {
      "date": "11 Dec 2025",
      "day": "Thu",
      "numbers": ["345", "67", "890"]
    },
    {
      "date": "10 Dec 2025",
      "day": "Wed",
      "numbers": ["456", "78", "901"]
    },
    {
      "date": "09 Dec 2025",
      "day": "Tue",
      "numbers": ["567", "89", "012"]
    },
    {
      "date": "08 Dec 2025",
      "day": "Mon",
      "numbers": ["678", "90", "123"]
    },
    {
      "date": "07 Dec 2025",
      "day": "Sun",
      "numbers": ["789", "01", "234"]
    },
    {
      "date": "06 Dec 2025",
      "day": "Sat",
      "numbers": ["890", "12", "345"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    // final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 cards per row
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: chartData.length,
          itemBuilder: (context, index) {
            final data = chartData[index];
            final numbers = data["numbers"] as List<String>;
            final redFlags = (data["red"] as List<bool>?) ??
                List.filled(numbers.length, false);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    color: Colors.grey[200],
                    child: Text(
                      "${data['day']}\n(${data['date']})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Numbers in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(numbers.length, (numIndex) {
                      return Text(
                        numbers[numIndex],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: redFlags[numIndex] ? Colors.red : Colors.black,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
