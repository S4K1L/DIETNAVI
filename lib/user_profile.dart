import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/login.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  User? user = FirebaseAuth.instance.currentUser;
  String userEmail = '';
  String age = '';
  String weight = '';
  String height = '';
  String activity = '';
  String goal = '';
  String excludedFoods = '';
  String breakfast = '';
  String lunch = '';
  String dinner = '';
  String calorieData = 'Loading calorie data...';

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userEmail = user!.email ?? 'No email found';
      _fetchCalorieData();
    }
  }

  Future<void> _fetchCalorieData() async {
    String userId = user!.uid; // Assuming the user is logged in
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection('calorieData').doc(userId);

    try {
      DocumentSnapshot snapshot = await documentReference.get();
      if (snapshot.exists) {
        setState(() {
          // Construct a string that includes all the details for display
          calorieData =
          'Details:\nCalories: ${snapshot['calories']?.toStringAsFixed(0) ?? 'N/A'}';
          age = 'Age: ${snapshot['age'] ?? 'N/A'}';
          weight = 'Weight: ${snapshot['weight'] ?? 'N/A'} kg';
          height = 'Height: ${snapshot['height'] ?? 'N/A'} cm';
          goal = 'Goal: ${snapshot['goal'] ?? 'N/A'}';
          breakfast = 'Breakfast: ${snapshot['breakfast'] ?? 'N/A'}';
          lunch = 'Lunch: ${snapshot['lunch'] ?? 'N/A'}';
          dinner = 'Dinner: ${snapshot['dinner'] ?? 'N/A'}';
          excludedFoods = 'Avoid: ${snapshot['excludedFoods'] ?? 'N/A'}';
          activity = 'Activity Level: ${snapshot['activityLevel'] ?? 'N/A'}';
        });
      } else {
        setState(() {
          calorieData = 'No calorie data found.';
        });
      }
    } catch (error) {
      setState(() {
        calorieData = 'Error fetching calorie data: $error';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: 400, height: 450),
                  user_data(),
                  const Positioned(
                      top: 0,
                      child: Icon(Icons.account_circle_outlined,size: 120, color: Colors.white,),
                  ),
                  const Positioned(
                    top: 100,
                    child: Chip(
                        backgroundColor: Colors.green,
                        label: Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Row(
                  children: [
                    Icon(
                      Icons.accessible_forward,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Logout Successfully",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3), // Adjust the duration as needed
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                //margin: EdgeInsets.all(20),
              ),);
              FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Container(
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "LOGOUT",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container user_data() {
    return Container(
                  height: 550,
                  width: 350,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                        'Email: $userEmail',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        calorieData,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        age,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        weight,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        height,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        goal,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activity,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        excludedFoods,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),

                    ],
                  ),
                );
  }
}