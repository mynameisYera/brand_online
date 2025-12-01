import 'package:flutter/material.dart';
import '../../roadMap/ui/screen/RoadMap.dart';

class BalanceWithdrawSuccessPage extends StatelessWidget {
  final int amount;

  const BalanceWithdrawSuccessPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                const Text(
                  'Өтініш жіберілді',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/brs4.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  '$amount',
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'қарастырылу 3 жұмыс күні ішінде*',
                  style: TextStyle(fontSize: 15, color: Colors.orange),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RoadMap(selectedIndx: 4, state: 0)),
                  ),
                  child: const Text(
                    'КЕРЕМЕТ!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
