import 'package:flutter/material.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/roadMap/entity/ControlExam.dart';
import 'package:brand_online/roadMap/service/task_service.dart';
import 'package:brand_online/roadMap/ui/screen/CustomAppBar.dart';
import 'package:brand_online/roadMap/ui/screen/NoTaskPage.dart';
import 'package:brand_online/synaq/page/mock_exam_screen.dart';
import 'package:brand_online/roadMap/ui/widget/repeat_cart.dart';

class SynaqPage extends StatefulWidget {
  const SynaqPage({super.key});

  @override
  State<SynaqPage> createState() => _SynaqPageState();
}

class _SynaqPageState extends State<SynaqPage> {
  final TaskService _taskService = TaskService();
  MockExam? _mockExam;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchMockExam();
  }

  Future<void> fetchMockExam() async {
    try {
      final result = await _taskService.getRestartLessons();
      if (!mounted) return;
      setState(() {
        _mockExam = result?.mockExam;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mockExam = null;
        _loading = false;
      });
    }
  }

  bool get _hasAny => _mockExam != null;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    if (!_hasAny) {
      return const NoTasksPage();
    }

    final body = RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: fetchMockExam,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CustomAppBar(),
                  const SizedBox(height: 16),
                  _MockExamCard(mockExam: _mockExam!, onStart: _onMockExamStart),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(child: body),
    );
  }

  void _onMockExamStart() async {
    if (_mockExam == null) return;
    final isDone = _mockExam!.attempt.isCompleted;
    if (isDone) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockExamScreen(exam: _mockExam!),
      ),
    );
    if (!mounted) return;
    fetchMockExam();
  }
}

class _MockExamCard extends StatelessWidget {
  const _MockExamCard({
    required this.mockExam,
    required this.onStart,
  });

  final MockExam mockExam;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final attempt = mockExam.attempt;
    final isCompleted = attempt.isCompleted;
    final subtitle = attempt.answeredCount > 0
        ? '${attempt.answeredCount}/${mockExam.taskCount} сұрақ · ${attempt.percentage.toStringAsFixed(0)}%'
        : '${mockExam.taskCount} сұрақ';

    return RepeatCart(
      subject: '${mockExam.gradeName} · ${mockExam.subjectName}',
      title: mockExam.title,
      subtitle: subtitle,
      mascotAsset: 'assets/images/SHOQAN.png',
      iconAsset: 'assets/icons/qortyndy.svg',
      onStart: onStart,
      isCompleted: isCompleted,
      color: AppColors.trueGreen,
    );
  }
}