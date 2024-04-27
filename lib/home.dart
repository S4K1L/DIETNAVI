import 'dart:developer';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/calorie-calculator.dart';
import 'package:food/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';

class NutritionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to login page or root of your app
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          DateAndGreeting(),
          const SizedBox(height: 20),
          MealsSection(),
          const SizedBox(height: 20),
          WorkoutSection(),
        ],
      ),
    );
  }
}

class DateAndGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMMM').format(now);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 20),
          ),
          // Display greeting with user's email (you can modify this based on your needs)
          FutureBuilder<String>(
            future: _getUserEmail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Text(
                'Hello, ${snapshot.data}',
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to get user's email (You can modify this based on your authentication method)
  Future<String> _getUserEmail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String email = user?.email ?? 'No email found';
    return email;
  }
}

class NutritionStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate the size for the button based on screen width
    final double size = MediaQuery.of(context).size.width * 0.5;

    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalorieCalculatorPage()),
          );
        },
        child: Container(
          width: size,
          height: size, // Makes the container circular
          decoration: const BoxDecoration(
            color: Colors.blue, // Button color
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.calculate,
              size: size * 0.5, // Icon size is half the button size
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressCirclePainter extends CustomPainter {
  final double percentage;
  final double lineWidth = 10.0;
  final Color lineColor = Colors.blue;
  final Color backgroundColor = Colors.grey.shade300;

  ProgressCirclePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    Paint foregroundPaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    double arcAngle = 2 * 3.141592653589793238 * percentage;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793238 / 2, arcAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MealsSection extends StatefulWidget {
  @override
  _MealsSectionState createState() => _MealsSectionState();
}

class _MealsSectionState extends State<MealsSection> {
  List<dynamic> meals = [];
  int userDailyCalorieNeeds = 2000; // Example value, fetch from user profile

  @override
  void initState() {
    super.initState();
    // _fetchMeals();
    _fetchUserCalorieNeeds(); // This will fetch calorie needs and then meals
  }

// Example keywords, expand these lists based on your own research or criteria
  List<String> lowerCalorieKeywords = [
    'salad',
    'broth',
    'grilled',
    'steamed',
    'raw'
  ];
  List<String> higherCalorieKeywords = [
    'fried',
    'creamy',
    'cheesy',
    'buttery',
    'stuffed'
  ];

  List<dynamic> categorizeMeals(List<dynamic> meals) {
    // This is a simplified categorization and might not be accurate
    return meals.where((meal) {
      String name = meal['strMeal'].toLowerCase();
      // Check if the meal name contains any of the lower calorie keywords
      bool isLowerCalorie =
      lowerCalorieKeywords.any((keyword) => name.contains(keyword));
      // Assuming you want to filter out higher calorie meals for a user
      return isLowerCalorie;
    }).toList();
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
        .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data.toString() + "===============================");
      List<dynamic> fetchedMeals = data['meals'];
      print(fetchedMeals.toString() + "===============================");

      // Filter meals based on calorie needs, assuming you have calorie information
      // This is a placeholder logic as actual calorie data from TheMealDB API is not available
      List<dynamic> filteredMeals = fetchedMeals.where((meal) {
        final estimatedMealCalories =
            Random().nextInt(600) + 200; // Simulate calorie estimation
        return estimatedMealCalories <= userDailyCalorieNeeds;
      }).toList();

      setState(() {
        meals = filteredMeals;
      });
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Fixed height for horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsPage(meal: meals[index]),
                ),
              );
            },
            child: // In the itemBuilder of ListView.builder in MealsSection
            MealCard(
              meal: meals[index],
              calories: Random().nextInt(600) + 200, // Your current logic
              userCalorieNeeds: userDailyCalorieNeeds, // Pass this in
            ),
          );
        },
      ),
    );
  }
}

class MealDetailsPage extends StatelessWidget {
  final dynamic meal;

  const MealDetailsPage({required this.meal});

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
                      fontSize: 24, fontWeight: FontWeight.bold),
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

class MealCard extends StatelessWidget {
  final dynamic meal;
  final int calories;
  final int userCalorieNeeds; // Add this

  const MealCard({
    required this.meal,
    required this.calories,
    required this.userCalorieNeeds, // Add this
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the meal is recommended based on calorie content
    bool isRecommended = calories <= userCalorieNeeds;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              meal['strMealThumb'],
              fit: BoxFit.cover,
              height: 80,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['strMeal'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${meal['strCategory']} - ${meal['strArea']}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  // Change color based on recommendation status
                  Text(
                    "Calories: $calories kcal",
                    style: TextStyle(
                      fontSize: 10,
                      color: isRecommended ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ... Your workout icons here ...
        ],
      ),
    );
  }
}