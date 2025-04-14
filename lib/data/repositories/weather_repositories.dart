import 'package:flutter_riverpod_todo_app/data/datasource/weather_service.dart';
import 'package:flutter_riverpod_todo_app/data/models/weather_model.dart';

class WeatherRepository {
  final WeatherService weatherService;

  WeatherRepository(this.weatherService);

  Future<Weather> getWeatherByCity(String cityName) async {
    final weatherData = await weatherService.fetchWeatherByCity(cityName);
    return Weather.fromJson(weatherData);
  }

  Future<String> getCurrentCity() async {
    return await weatherService.getCurrentCity();
  }
}
