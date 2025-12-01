import 'package:flutter/material.dart';
import '../../general/GeneralUtil.dart';
import '../service/profile_service.dart';
import 'BalanceWithdrawSuccessPage.dart';

class BalanceWithdrawalPage extends StatefulWidget {
  final int currentBalance;
  const BalanceWithdrawalPage({Key? key, required this.currentBalance}) : super(key: key);

  @override
  State<BalanceWithdrawalPage> createState() => _BalanceWithdrawalPageState();
}

class _BalanceWithdrawalPageState extends State<BalanceWithdrawalPage> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal(int amount) async {
    print("Submitted loading.....");
    // FocusScope.of(context).unfocus();
    // if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    if(int.parse(_amountController.text) >= 3000){
      try {
      print("started trying....");
      await ProfileService().withdrawBalance(int.parse(_amountController.text));
      print("amount: $amount");

      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BalanceWithdrawSuccessPage(amount: int.parse(_amountController.text)),
        ),
      );

      if (result == true) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сервер қатесі кейінірек қайталап көріңіз')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('3000 теңгеден жоғары шығаруға болады...')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // title: const Text('Бонус шығару', style: TextStyle(fontSize: 15),),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              Text(
                '${widget.currentBalance} бонус',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: GeneralUtil.blueColor,
                ),
              ),
              const SizedBox(height: 32),

              // Поле ввода
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'шығаратын бонус',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixText: 'бонус',
                      suffixStyle: TextStyle(color: Colors.grey.shade600),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: GeneralUtil.blueColor, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'С енгізіңіз';
                      final val = int.tryParse(v);
                      if (val == null) return 'Жарамсыз С';
                      if (val <= 0) return 'С оң болуы керек';
                      if (val < 3000) return 'С 3000 асу керек';
                      if (val > widget.currentBalance) return 'Сдан артық берілмейді';
                      return null;
                    },
                  ),
                ),
              ),

              Expanded(child: Container()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                      ? null
                      : () {
                          if (widget.currentBalance < 3000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Минималды — 3000'),
                              ),
                            );
                            return;
                          }


                          _submitWithdrawal(widget.currentBalance);
                        },

                    label: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : const Text(
                      'өтініш жіберу',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: _isSubmitting
                        ? const SizedBox.shrink()
                        : const Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 40,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GeneralUtil.blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}