import 'package:flutter/material.dart';
import 'package:brand_online/roadMap/service/task_service.dart';
import 'package:brand_online/roadMap/ui/widget/custom_button_widget.dart';

class ErrorOccuredBottomWidget extends StatefulWidget {
  final String taskId;
  const ErrorOccuredBottomWidget({super.key, required this.taskId});

  @override
  State<ErrorOccuredBottomWidget> createState() => _ErrorOccuredBottomWidgetState();
}

class _ErrorOccuredBottomWidgetState extends State<ErrorOccuredBottomWidget> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> sender() async{
    String answer = await TaskService().sendReport(taskId: widget.taskId, message: _controller.text);
    print(answer);
    return answer;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Сұрақтан қате таптыңыз ба?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Не дұрыс емес?';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Қатені сипаттап жазыңыз...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),
            CustomButtonWidget(
              color: Colors.blue, 
              text: "Жіберу", 
              onTap: (){
                if(_formKey.currentState!.validate()){
                  sender();
                  Navigator.pop(context);
                }
              }
            ),
            SizedBox(height: 40,)
          ],
        ),
      )
    );
  }
}