import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_todo_app/config/config.dart';
import 'package:flutter_riverpod_todo_app/data/datasource/weather_service.dart';
import 'package:flutter_riverpod_todo_app/data/models/weather_model.dart';
import 'package:flutter_riverpod_todo_app/data/repositories/weather_repositories.dart';
import 'package:flutter_riverpod_todo_app/providers/providers.dart'; // Task-related providers
import 'package:flutter_riverpod_todo_app/utils/utils.dart';
import 'package:flutter_riverpod_todo_app/widgets/widgets.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../data/models/task.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final WeatherRepository weatherRepository =
  WeatherRepository(WeatherService());
  Weather? weather;
  bool isWeatherLoading = true;
  String? weatherError;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      isWeatherLoading = true;
      weatherError = null;
    });

    try {
      final cityName = await weatherRepository.getCurrentCity();
      final fetchedWeather = await weatherRepository.getWeatherByCity(cityName);
      setState(() {
        weather = fetchedWeather;
      });
    } catch (e) {
      setState(() {
        weatherError = e.toString();
      });
    } finally {
      setState(() {
        isWeatherLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

    // Use Riverpod providers for task management
    final taskState = ref.watch(tasksProvider);
    final date = ref.watch(dateProvider);
    final inCompletedTasks = _filterIncompleteTasks(taskState.tasks, date);
    final completedTasks = _filterCompletedTasks(taskState.tasks, date);

    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            headerHeight: deviceSize.height * 0.3,
            header: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Helpers.selectDate(context, ref),
                    child: DisplayWhiteText(
                      text: Helpers.dateFormatter(date),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const DisplayWhiteText(
                    text: 'My Todo List',
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Weather Card (Manual State Management)
                    if (isWeatherLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (weatherError != null)
                      Text(
                        'Error fetching weather: $weatherError',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (weather != null)
                        Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weather in ${weather!.cityName}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Temperature: ${weather!.temperature}°C',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  'Condition: ${weather!.description}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                    // Task Lists (Using Providers)
                    const Text(
                      'Incomplete Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 200, // Limit the height of incomplete tasks
                      child: DisplayListOfTasks(
                        tasks: inCompletedTasks,
                      ),
                    ),
                    const Gap(20),
                    const Text(
                      'Completed Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 200, // Limit the height of completed tasks
                      child: DisplayListOfTasks(
                        isCompletedTasks: true,
                        tasks: completedTasks,
                      ),
                    ),
                    const Gap(20),
                    ElevatedButton(
                      onPressed: () => context.push(RouteLocation.createTask),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        'Add New Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Task> _filterIncompleteTasks(List<Task> tasks, DateTime date) {
    return tasks.where((task) {
      return !task.isCompleted && Helpers.isTaskFromSelectedDate(task, date);
    }).toList();
  }

  List<Task> _filterCompletedTasks(List<Task> tasks, DateTime date) {
    return tasks.where((task) {
      return task.isCompleted && Helpers.isTaskFromSelectedDate(task, date);
    }).toList();
  }
}
