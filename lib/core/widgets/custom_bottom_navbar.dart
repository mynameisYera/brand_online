import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../roadMap/entity/ProfileController.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: currentIndex,
            onTap: onTap,
            items: [
        // Главная (Main)
        BottomNavigationBarItem(
          icon: Column(
            children: [
              SvgPicture.asset(
                currentIndex == 0
                    ? 'assets/icons/main_active.svg'
                    : 'assets/icons/main.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 5),
              if (currentIndex == 0)
                Container(
                  height: 3,
                  width: 20,
                  color: Colors.blue,
                )
            ],
          ),
          label: '',
        ),
        // Повтор (Tasks)
        BottomNavigationBarItem(
          icon: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    currentIndex == 1
                        ? 'assets/icons/tasks_active.svg'
                        : 'assets/icons/tasks.svg',
                    width: 24,
                    height: 24,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: ValueListenableBuilder<int>(
                      valueListenable: ProfileController.repeatLessonsCountNotifier,
                      builder: (_, count, __) {
                        if (count <= 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (currentIndex == 1)
                Container(
                  height: 3,
                  width: 20,
                  color: Colors.blue,
                )
            ],
          ),
          label: '',
        ),
        // Новости (News)
        BottomNavigationBarItem(
          icon: Column(
            children: [
              SvgPicture.asset(
                currentIndex == 2
                    ? 'assets/icons/news_active.svg'
                    : 'assets/icons/news.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 5),
              if (currentIndex == 2)
                Container(
                  height: 3,
                  width: 20,
                  color: Colors.blue,
                )
            ],
          ),
          label: '',
        ),
        // Лидерборд (archive/Trophy)
        BottomNavigationBarItem(
          icon: Column(
            children: [
              SvgPicture.asset(
                currentIndex == 3
                    ? 'assets/icons/archive_active.svg'
                    : 'assets/icons/archive.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 5),
              if (currentIndex == 3)
                Container(
                  height: 3,
                  width: 20,
                  color: Colors.blue,
                )
            ],
          ),
          label: '',
        ),
        // Профиль (Profile)
        BottomNavigationBarItem(
          icon: Column(
            children: [
              SvgPicture.asset(
                currentIndex == 4
                    ? 'assets/icons/profile_active.svg'
                    : 'assets/icons/profile.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 5),
              if (currentIndex == 4)
                Container(
                  height: 3,
                  width: 20,
                  color: Colors.blue,
                )
            ],
          ),
          label: '',
        ),
      ],
    ),
          ),
        ),
      );
  }
}
