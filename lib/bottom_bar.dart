import 'package:flutter/material.dart';
import 'package:food/user_profile.dart';
import 'calorie-calculator.dart';
import 'excercise_screen.dart';
import 'home.dart';
import 'meal_list.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomBarState();
}

class _BottomBarState extends State<Bottom> {
  int index_color = 0;
  List Screen = [NutritionApp(),MealsSectionFood(),ProfileView(),ExercisePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Screen[index_color],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const CalorieCalculatorPage()));
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 0;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 30,
                    color: index_color == 0 ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 1;
                    });
                  },
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 30,
                    color: index_color == 1 ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 3;
                    });
                  },
                  child: Icon(
                    Icons.workspace_premium,
                    size: 30,
                    color: index_color == 3 ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      index_color = 2;
                    });
                  },
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: index_color == 2 ? Colors.blue : Colors.grey,
                  ),
                ),

              ],
            ),
          ),
        ));
  }
}