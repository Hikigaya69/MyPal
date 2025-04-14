class Weather {
  final String cityName;
  final double temperature;
  final String description;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['location']['name'], // Extract city name from "location"
      temperature: json['current']['temp_c'], // Temperature in Celsius from "current"
      description: json['current']['condition']['text'], // Weather condition text
    );
  }
}
