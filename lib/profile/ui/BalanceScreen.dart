import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:brand_online/profile/ui/BalanceWithdrawalPage.dart';
import '../entity/WalletTransaction.dart';
import '../service/profile_service.dart';

class BalanceScreen extends StatefulWidget {
  final int currentBalance;
  const BalanceScreen({Key? key, required this.currentBalance}) : super(key: key);

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  List<WalletTransaction> transactions = [];
  bool isLoading = true;

  int currentBalance = 0;
  List<WalletTransaction> transactionHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
    fetchProfileAndHistory();
  }

  Future<void> loadHistory() async {
    try {
      final history = await ProfileService().getTransactionHistory();
      setState(() {
        transactions = history;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTransactionTile(WalletTransaction tx) {
    final date = DateFormat('dd.MM.yyyy').format(tx.createdAt);
    final isPositive = tx.amount >= 0;
    final String? txStatus = tx.metadata['status'];
    final bool isWithdraw = tx.type == 'withdraw';

    // Цвет суммы
    final Color color = () {
      if (isWithdraw) {
        switch (txStatus) {
          case 'pending':
            return Color.fromRGBO(255, 217, 66, 1); // жёлтый
          case 'approved':
            return Colors.blue;
          case 'rejected':
            return Colors.red;
          default:
            return Colors.grey;
        }
      }

      if (isPositive) {
        if (tx.type == 'cashback' || tx.type == 'scholarship' || tx.type == 'strike') {
          return Colors.green;
        }
        return Colors.orange;
      }

      return Colors.red;
    }();

    // Иконка
    final icon = () {
      if (isWithdraw && txStatus == 'pending') {
        return '⏳';
      }

      const icons = {
        'strike': '🔥',
        'scholarship': '🎓',
        'cashback': '💰',
        'withdraw': '💳',
      };
      return icons[tx.type] ?? '💸';
    }();

    // Стиль суммы
    final TextStyle amountStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      decoration: (isWithdraw && txStatus == 'rejected')
          ? TextDecoration.lineThrough
          : TextDecoration.none,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.text,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isPositive ? '+' : ''}${tx.amount}",
            style: amountStyle,
          ),
        ],
      ),
    );
  }




  Future<void> fetchProfileAndHistory() async {
    try {
      final profile = await ProfileService().getStudentProfile();

      final history = await ProfileService().getTransactionHistory();

      if (mounted) {
        setState(() {
          currentBalance = profile!.permanent_balance;
          transactionHistory = history;
        });
      }
    } catch (e) {
      print('Ошибка при обновлении данных: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text("Бонус", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
          : Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  '${widget.currentBalance} бонус',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BalanceWithdrawalPage(currentBalance: widget.currentBalance),
                          ),
                        );

                        if (result == true && mounted) {
                          setState(() {
                            fetchProfileAndHistory();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Өтінім жіберу",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text("Бонус тарихы",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 30),
                    itemCount: transactions.length,
                    itemBuilder: (_, index) =>
                        _buildTransactionTile(transactions[index]),
                  ),
                ),
              ],
            ),
    );
  }
}
