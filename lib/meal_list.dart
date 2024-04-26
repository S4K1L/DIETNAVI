import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealsSectionFood extends StatefulWidget {
  const MealsSectionFood({super.key});

  @override
  _MealsSectionFoodState createState() => _MealsSectionFoodState();
}

class _MealsSectionFoodState extends State<MealsSectionFood> {
  List<dynamic> meals = [];
  int userDailyCalorieNeeds = 2000; // Example value, fetch from user profile
  final Map<String, List<dynamic>> categorizedMeals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  String selectedMealTime = 'All'; // Initially show all meals

  @override
  void initState() {
    super.initState();
    _fetchMeals();
    _fetchUserCalorieNeeds(); // This will fetch calorie needs and then meals
  }

  Future<void> _fetchUserCalorieNeeds() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      DocumentReference documentReference =
      FirebaseFirestore.instance.collection('calorieData').doc(userId);

      try {
        DocumentSnapshot snapshot = await documentReference.get();
        if (snapshot.exists && snapshot.data() != null) {
          final userData = snapshot.data() as Map<String, dynamic>;
          setState(() {
            userDailyCalorieNeeds = userData['calories'].round();
            // Now that we have calorie needs, fetch meals
            _fetchMeals();
          });
        }
      } catch (error) {
        print("Error fetching user calorie data: $error");
      }
    }
  }

  Future<void> _fetchMeals() async {
    // Example fetching process
    final response = await http
        .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> fetchedMeals = data['meals'];

      // Filter meals based on calorie needs
      List<dynamic> filteredMeals = fetchedMeals.where((meal) {
        final estimatedMealCalories = Random().nextInt(600) + 200; // Simulate calorie estimation
        return estimatedMealCalories <= userDailyCalorieNeeds;
      }).toList();

      // Categorize meals (assuming category information exists in fetched meals)
      for (var meal in filteredMeals) {
        String category = meal['strMeal'].toLowerCase();
        if (category.contains('breakfast')) {
          categorizedMeals['Breakfast']!.add(meal);
        } else if (category.contains('lunch')) {
          categorizedMeals['Lunch']!.add(meal);
        } else if (category.contains('dinner')) {
          categorizedMeals['Dinner']!.add(meal);
        }
      }

      setState(() {
        meals = filteredMeals;
      });
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredMeals(selectedMealTime).length,
              itemBuilder: (context, index) {
                final filteredMeal = _getFilteredMeals(selectedMealTime)[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Meal_Food_DetailsPage(
                          meal: filteredMeal,
                        ),
                      ),
                    );
                  },
                  child: Meal_Food_Card(
                    meal: filteredMeal,
                    calories: Random().nextInt(600) + 200,
                    userCalorieNeeds: userDailyCalorieNeeds,
                    category: filteredMeal['strMeal'].contains('breakfast')
                        ? 'Breakfast'
                        : filteredMeal['strMeal'].contains('lunch')
                        ? 'Lunch'
                        : 'Dinner',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to filter meals based on selected meal time
  List<dynamic> _getFilteredMeals(String selectedTime) {
    if (selectedTime == 'All') {
      return meals;
    } else {
      return categorizedMeals[selectedTime]!;
    }
  }
}

class Meal_Food_DetailsPage extends StatelessWidget {
  final dynamic meal;

  const Meal_Food_DetailsPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['strMeal']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['strMeal'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Image.network(
                  meal['strMealThumb'],
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  meal['strInstructions'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Meal_Food_Card extends StatefulWidget {
  final dynamic meal;
  final int calories;
  final int userCalorieNeeds; // Add this
  final String category;

  const Meal_Food_Card({
    super.key,
    required this.meal,
    required this.calories,
    required this.userCalorieNeeds,
    required this.category,
  });

  @override
  State<Meal_Food_Card> createState() => _Meal_Food_CardState();
}

class _Meal_Food_CardState extends State<Meal_Food_Card> {
  @override
  Widget build(BuildContext context) {
    // Determine if the meal is recommended based on calorie content
    bool isRecommended = widget.calories <= widget.userCalorieNeeds;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.meal['strMealThumb'],
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meal['strMeal'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Calories: ${widget.calories} kcal",
                      style: TextStyle(
                        fontSize: 10,
                        color: isRecommended ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      "Category: ${widget.category}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}