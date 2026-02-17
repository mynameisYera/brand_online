import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RepeatCart extends StatefulWidget {
  const RepeatCart({
    super.key,
    required this.subject,
    required this.title,
    required this.mascotAsset,
    required this.iconAsset,
    required this.onStart,
    required this.isCompleted,
    required this.color,
    this.subtitle,
    this.status,
  });

  final String subject;
  final String title;
  final String? subtitle;
  final String mascotAsset;
  final String iconAsset;
  final VoidCallback onStart;
  final bool isCompleted;
  final Color color;
  final String? status;

  @override
  State<RepeatCart> createState() => _RepeatCartState();
}

class _RepeatCartState extends State<RepeatCart> {
  bool expanded = false;

  void onViewResult() async {
    
    //  await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SynaqResultPage(
    //       answer: widget.answer,
    //     ),
    //   ),
    // );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          expanded = !expanded;
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          // image: DecorationImage(image: AssetImage("assets/images/oyu.png"), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: expanded ? 55 : 0,
              child: Image.asset(widget.mascotAsset, width: 100, height: 100, fit: BoxFit.cover),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.all(7),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(widget.iconAsset),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: TextStyles.semibold(AppColors.white, fontSize: 16),),
                        if (widget.subtitle != null) Text(widget.subtitle!, style: TextStyles.medium(AppColors.white, fontSize: 9),),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(widget.subject, style: TextStyles.semibold(AppColors.white, fontSize: 16),),
                  ],
                ),
                expanded ? const SizedBox(height: 12) : const SizedBox.shrink(),

                expanded
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ButtonWidget(
                          widget: Text(
                            widget.isCompleted ? 'Нәтижесін көру' : 'Бастау',
                            style: TextStyles.bold(widget.color, fontSize: 16),
                          ),
                          color: AppColors.white,
                          textColor: AppColors.black,
                          onPressed: widget.onStart,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 16),
              ],
            ),
          ],
        )
      ),
    );
  }
}