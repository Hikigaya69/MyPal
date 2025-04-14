// widgets/weather_card.dart

import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather in ${weather['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Temperature: ${weather['main']['temp']}°C'),
            Text('Condition: ${weather['weather'][0]['description']}'),
          ],
        ),
      ),
    );
  }
}
