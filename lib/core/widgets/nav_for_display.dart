import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/roadMap/entity/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavForDisplay extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavForDisplay({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: 210,
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey, width: 1),
            ),
            child: Column(
              children: [
                _navItem(
                  index: 0,
                  label: 'Басты бет',
                  icon: 'assets/icons/main.svg',
                  activeIcon: 'assets/icons/main_active.svg',
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<int>(
                  valueListenable: ProfileController.repeatLessonsCountNotifier,
                  builder: (_, count, __) {
                    return _navItem(
                      index: 1,
                      label: 'Қайталау сабақтары',
                      icon: 'assets/icons/tasks.svg',
                      activeIcon: 'assets/icons/tasks_active.svg',
                      badgeCount: count,
                    );
                  },
                ),
                const SizedBox(height: 10),
                _navItem(
                  index: 2,
                  label: 'Жаңалықтар',
                  icon: 'assets/icons/news.svg',
                  activeIcon: 'assets/icons/news_active.svg',
                ),
                const SizedBox(height: 10),
                _navItem(
                  index: 3,
                  label: 'Үздіктер тізімі',
                  icon: 'assets/icons/archive.svg',
                  activeIcon: 'assets/icons/archive_active.svg',
                ),
                const SizedBox(height: 10),
                _navItem(
                  index: 4,
                  label: 'Профиль',
                  icon: 'assets/icons/profile.svg',
                  activeIcon: 'assets/icons/profile_active.svg',
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      )
    );
  }

  Widget _navItem({
    required int index,
    required String label,
    required String icon,
    required String activeIcon,
    int badgeCount = 0,
  }) {
    final isActive = currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap(index),
      child: Container(
        width: 180,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.grey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _iconWithBadge(
              path: isActive ? activeIcon : icon,
              badgeCount: badgeCount,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyles.medium(
                  isActive ? AppColors.primaryBlue : AppColors.grey,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWithBadge({required String path, int badgeCount = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(path, width: 18, height: 18),
        if (badgeCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
