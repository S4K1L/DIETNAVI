import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalorieCalculatorPage extends StatefulWidget {
  const CalorieCalculatorPage({super.key});

  @override
  _CalorieCalculatorPageState createState() => _CalorieCalculatorPageState();
}

class _CalorieCalculatorPageState extends State<CalorieCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  int? age, weight, height;
  double activityLevelFactor = 1.2; // Sedentary by default
  String? selectedActivityLevel;

  final Map<String, double> activityLevels = {
    "Sedentary: little or no exercise": 1.2,
    "Lightly active (light exercise/sports 1-3 days/week)": 1.375,
    "Moderately active (moderate exercise/sports 3-5 days/week)": 1.55,
    "Very active (hard exercise/sports 6-7 days a week)": 1.725,
    "Super active (very hard exercise/sports & physical job)": 1.9,
  };

  Future<void> _saveCalorieData(double calories, String goal, String excludedFoods, double bmi) async {
    User? currentUser =
        FirebaseAuth.instance.currentUser; // Get the current user
    if (currentUser != null) {
      String userId = currentUser.uid; // Use the UID as the unique identifier

      // Reference to Firestore collection
      CollectionReference calorieData =
          FirebaseFirestore.instance.collection('calorieData');

      // Add or update the user's calorie data along with other details
      await calorieData.doc(userId).set({
        'userId': userId,
        'calories': calories,
        'age': age, // Save the age
        'weight': weight, // Save the weight
        'height': height,
        'goal': goal,
        'excludedFoods': excludedFoods,
        'bmi': bmi,
        'activityLevel':
            selectedActivityLevel, // Save the selected activity level
        'timestamp': FieldValue
            .serverTimestamp(), // Optional: capture the time of calculation
      }).catchError((error) => print("Failed to save calorie data: $error"));
    } else {
      print("No user logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) {
                  weight = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) {
                  height = int.parse(value!);
                },
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Activity Level',
                ),
                isExpanded: true, // Ensure the dropdown button expands to fill available space
                items: activityLevels.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivityLevel = value.toString();
                    activityLevelFactor = activityLevels[value]!;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select an activity level' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _calculateAndShowCalories(context),
                  child: const Text('Calculate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateAndShowCalories(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Example calculation for men: 10 * weight (kg) + 6.25 * height (cm) - 5 * age (y) + 5
      // For women: 10 * weight (kg) + 6.25 * height (cm) - 5 * age (y) - 161
      // Adjust the formula according to your needs
      // Note: This example assumes a male user. You should add gender selection for accuracy.

      double bmr =
          (10 * weight!) + (6.25 * height!) - (5 * age!) + 5; // BMR for men

      //double bmi = (weight! / ((height! / 100) * (height! / 100)));
      double bmi = weight! / ((height! / 100) * (height! / 100));

      double calories = bmr * activityLevelFactor;

      String goal = showWeightGoal(context, bmi);
      String excludedFoods = showExcludedFoods(context, bmi);

      _saveCalorieData(calories, goal, excludedFoods, bmi);
      // Show the result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Daily Calorie Needs'),
          content: Text(
              'Your estimated daily calorie needs are: ${calories.toStringAsFixed(0)} calories'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String showWeightGoal(BuildContext context, double bmi) {
    String goal;

    // Determine goal based on BMI ranges
    if (bmi < 18.5) {
      goal = "Gain weight (underweight)";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      goal = "Maintain weight (normal weight)";
    } else if (bmi >= 24.9 && bmi < 29.9) {
      goal = "Lose weight (overweight)";
    } else if (bmi >= 29.9 && bmi < 34.9) {
      goal = "Lose weight (obese class I) - Aim to lose 5-10% of current body weight";
    } else if (bmi >= 34.9 && bmi < 39.9) {
      goal = "Lose weight (obese class II) - Aim to lose 10-20% of current body weight";
    } else {
      goal = "Lose weight (obese class III) - Aim to lose 20% or more of current body weight";
    }

    return goal;
  }

  String showExcludedFoods(BuildContext context, double bmi) {
    String excludedFoods;

    // Determine excluded foods based on BMI ranges or weight categories
    if (bmi < 18.5) {
      return excludedFoods = "Sugary snacks, Fried foods, Processed foods";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return excludedFoods = "Normal weight, no excluded foods"; // For normal weight, no excluded foods
    } else if (bmi >= 24.9 && bmi < 29.9) {
      return excludedFoods = "Sugary drinks, Fried foods"; // For overweight
    } else {
      return excludedFoods = "High-sugar desserts, Fried foods, Processed meats";
    }
  }

}
