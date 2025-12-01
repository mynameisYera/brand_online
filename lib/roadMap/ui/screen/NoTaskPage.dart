import 'package:flutter/material.dart';

class NoTasksPage extends StatelessWidget {
  const NoTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/admbarys.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'әзірге тапсырмалар жоқ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}