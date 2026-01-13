import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: SizedBox(),
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
                '${widget.currentBalance}₸',
                style: TextStyles.bold(AppColors.primaryBlue, fontSize: 28),
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Сома',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixText: '₸',
                      suffixStyle: TextStyles.regular(AppColors.black, fontSize: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: GeneralUtil.blueColor, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Сомма енгізіңіз';
                      final val = int.tryParse(v);
                      if (val == null) return 'Жарамсыз сомма';
                      if (val <= 0) return 'Сомма оң болуы керек';
                      if (val < 3000) return 'Сомма 3000 асу керек';
                      if (val > widget.currentBalance) return 'Балансыңыздағы сома жеткіліксіз';
                      return null;
                    },
                  ),
                ),
              ),

              Expanded(child: Container()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ButtonWidget(
                  isLoading: _isSubmitting,
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/plane.svg", color: AppColors.white,),
                      SizedBox(width: 8),
                      Text('Өтініш жіберу', style: TextStyles.bold(AppColors.white, fontSize: 16)),
                    ],
                  ), 
                  color: AppColors.primaryBlue, 
                  textColor: AppColors.white, 
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitWithdrawal(int.parse(_amountController.text));
                    }
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}