import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../authorization/entity/ProfileResponse.dart';
import '../../../authorization/service/auth_service.dart';
import '../../../news/ui/NewsListPage.dart';
import '../../../profile/ui/ProfilePage.dart';
import '../../../leaderboard/ui/LeaderboardPage.dart';
import '../../../core/widgets/custom_bottom_navbar.dart';
import '../../entity/ProfileController.dart';
import 'RepeatPage.dart';
import 'RoadMainPage.dart';

class RoadMap extends StatefulWidget {
  final double initialScrollOffset;
  final int selectedIndx;
  final int state;

  const RoadMap(
      {Key? key,
      this.initialScrollOffset = 0,
      required this.selectedIndx,
      required this.state})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoadMapState();
}

class _RoadMapState extends State<RoadMap> {
  late ProfileResponse profileResponse = ProfileResponse(
      permanent_balance: 0,
      temporary_balance: 0,
      id: 1,
      role: 0,
      grade: 0,
      strike: "0",
      points: "0",
      multiplier: "0",
      repeatLessonsCount: 0,
      selectedGrade: null,
      permanentBalance: 0,
      temporaryBalance: 0,
      gradeBalances: []);
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    getProfile();
    _selectedIndex = widget.selectedIndx;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    int index = (offset / 150).floor();

    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    getProfile();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> getProfile() async {
    final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final token = await storage.read(key: 'auth_token');
    if (token == null) return;

    final res = await AuthService().getProfile(token, context);
    if (!mounted) return;
    if (res != null) {
      ProfileController.updateFromProfile(res);
      setState(() {
        profileResponse = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 0
        // ? NoSubPageIos(whatsappUrl: "whatsappUrl")
          ? RoadMainPage(
              initialScrollOffset: widget.initialScrollOffset,
              state: widget.state,
            )
          : _selectedIndex == 1
              ? RepeatPage()
              : _selectedIndex == 2
                  ? NewsListPage()
                  : _selectedIndex == 3
                      ? LeaderboardPage()
                      : ProfilePage(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
