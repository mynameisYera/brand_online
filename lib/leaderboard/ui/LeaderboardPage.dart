import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../general/GeneralUtil.dart';
import '../service/leaderboard_service.dart';
import '../entity/LeaderboardResponse.dart';
import '../entity/LeaderboardEntry.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  LeaderboardResponse? leaderboard;
  bool isLoading = true;
  late String classTitle;
  int selectedIndex = 1;
  late PageController _pageController;
  LeaderboardResponse? weeklyLeaderboard;
  LeaderboardResponse? monthlyLeaderboard;
  LeaderboardResponse? totalLeaderboard;

  final List<String> titles = ['Апта', 'Ай', 'Жалпы'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
    _initWithSplashDelay();
  }

  LeaderboardResponse? get currentLeaderboard {
    switch (selectedIndex) {
      case 0:
        return weeklyLeaderboard;
      case 1:
        return monthlyLeaderboard;
      case 2:
        return totalLeaderboard;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initWithSplashDelay() async {
    setState(() => isLoading = true);

    final weeklyFuture = LeaderboardService().getLeaderBoardByType(0);
    final monthlyFuture = LeaderboardService().getLeaderBoardByType(1);
    final totalFuture = LeaderboardService().getLeaderBoardByType(2);

    final results = await Future.wait([
      weeklyFuture,
      monthlyFuture,
      totalFuture,
      Future.delayed(const Duration(milliseconds: 300)),
    ]);

    setState(() {
      weeklyLeaderboard = results[0] as LeaderboardResponse;
      monthlyLeaderboard = results[1] as LeaderboardResponse;
      totalLeaderboard = results[2] as LeaderboardResponse;

      leaderboard = results[selectedIndex] as LeaderboardResponse;

      int? grade = monthlyLeaderboard?.top20[0].grade;
      classTitle = '$grade-класс';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final top20 = currentLeaderboard?.top20 ?? [];
    final yourRank =
        (currentLeaderboard != null) ? currentLeaderboard!.yourRank + 1 : 0;

    if (isLoading) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
            child: Center(
              child: LoadingAnimationWidget.progressiveDots(
                color: GeneralUtil.mainColor,
                size: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
          ));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            child: Text(
              'Үздіктер $classTitle',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),

          /// Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(titles.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[300] : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 46),

          /// Top 3 users
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TopCircle(
                name: top20.length > 1 ? top20[1].firstName : '',
                index: 1,
                color: Color.fromRGBO(205, 205, 205, 1),
                size: 90,
                cash: currentLeaderboard!.secondPlace,
              ),
              _TopCircle(
                name: top20.isNotEmpty ? top20[0].firstName : '',
                index: 0,
                color: Color.fromRGBO(255, 196, 0, 1),
                size: 120,
                cash: currentLeaderboard!.firstPlace,
              ),
              _TopCircle(
                name: top20.length > 2 ? top20[2].firstName : '',
                index: 2,
                color: Color.fromRGBO(205, 142, 70, 1),
                size: 90,
                cash: currentLeaderboard!.thirdPlace,
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Top 20 list
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: titles.length,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final pageLeaderboard = index == 0
                    ? weeklyLeaderboard
                    : index == 1
                        ? monthlyLeaderboard
                        : totalLeaderboard;
                final top20 = pageLeaderboard?.top20 ?? [];
                final yourRank = (pageLeaderboard?.yourRank ?? -1) + 1;

                return ListView.builder(
                  itemCount: top20.length,
                  itemBuilder: (context, i) {
                    final user = top20[i];
                    final isCurrentUser = i + 1 == yourRank;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == 0
                              ? Color.fromRGBO(255, 196, 0, 1)
                              : i == 1
                                  ? Color.fromRGBO(205, 205, 205, 1)
                                  : i == 2
                                      ? Color.fromRGBO(205, 142, 70, 1)
                                      : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrentUser
                              ? Border.all(
                                  color: GeneralUtil.mainColor, width: 2)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: ListTile(
                          leading: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                user.firstName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (user.strike > 0)
                                Row(
                                  children: [
                                    Image.asset('assets/images/fire1.png',
                                        width: 20),
                                    Text(
                                      '${user.strike}',
                                      style: TextStyle(
                                          color: GeneralUtil.orangeColor),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${_getPointsBySelectedType(user)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Your Rank
          if (yourRank > 20)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: ListTile(
                leading: Text(
                  '${yourRank}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      leaderboard?.you.firstName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (leaderboard!.you.strike > 0)
                      Row(
                        children: [
                          Image.asset('assets/images/fire1.png', width: 20),
                          Text(
                            '${leaderboard!.you.strike}',
                            style: TextStyle(color: GeneralUtil.orangeColor),
                          ),
                        ],
                      ),
                  ],
                ),
                trailing: Text(
                  '${_getPointsBySelectedType(leaderboard!.you)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),)
    );
  }

  int _getPointsBySelectedType(LeaderboardEntry user) {
    switch (selectedIndex) {
      case 0:
        return user.weeklyPoints;
      case 1:
        return user.monthlyPoints;
      case 2:
      default:
        return user.points;
    }
  }
}

class _TopCircle extends StatelessWidget {
  final String name;
  final int index; // 0, 1, 2
  final Color color;
  final double size;
  final int cash;

  const _TopCircle({
    required this.name,
    required this.index,
    required this.color,
    this.size = 70,
    required this.cash,
  });

  String getRomanText(int index) {
    switch (index) {
      case 0:
        return 'I';
      case 1:
        return 'II';
      case 2:
        return 'III';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size + 60,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (index == 0)
                const Positioned(
                  top: -40,
                  child: Image(
                    image: AssetImage('assets/images/crown.png'),
                    width: 60,
                    height: 60,
                  ),
                ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Center(
                  child: Text(
                    getRomanText(index),
                    style: GoogleFonts.robotoSerif(
                      fontSize: size / 2,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          (cash > 0)
              ? Text(
                  '$cash',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                )
              : Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
        ],
      ),
    );
  }
}
