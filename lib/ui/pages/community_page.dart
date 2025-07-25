import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gh6_ucap/bloc/community/community_bloc.dart';
import 'package:gh6_ucap/models/community_model.dart';
import 'package:gh6_ucap/services/community_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommunityBloc(
        communityRepository: CommunityRepository(),
      )..add(FetchCommunityData()),
      child: const CommunityView(),
    );
  }
}

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});
  @override
  _CommunityViewState createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  late PageController _pageController;
  int _selectedTab = 0;
  bool _isCreatingQuestion = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Set timezone untuk timeago
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5EE),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Komunitas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: BlocConsumer<CommunityBloc, CommunityState>(
              listener: (context, state) {
                if (state is CommunityError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (state is CommunityQuestionCreated) {
                  setState(() => _isCreatingQuestion = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Pertanyaan berhasil dibuat!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (state is CommunityCreatingQuestion) {
                  setState(() => _isCreatingQuestion = true);
                }
              },
              builder: (context, state) {
                if (state is CommunityLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  );
                }
                
                if (state is CommunityLoaded || state is CommunityCreatingQuestion) {
                  final questions = state is CommunityLoaded 
                      ? state.questions 
                      : (state as CommunityCreatingQuestion).questions;
                  final mentors = state is CommunityLoaded 
                      ? state.mentors 
                      : (state as CommunityCreatingQuestion).mentors;
                      
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CommunityBloc>().add(RefreshCommunityData());
                    },
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _selectedTab = index),
                      children: [
                        _buildForumPage(questions),
                        _buildMentorPage(mentors),
                      ],
                    ),
                  );
                }
                
                if (state is CommunityError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CommunityBloc>().add(FetchCommunityData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const Center(child: Text('Silakan coba lagi.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _isCreatingQuestion ? null : () {
                HapticFeedback.lightImpact();
                _showCreateQuestionDialog(context);
              },
              backgroundColor: _isCreatingQuestion 
                  ? Colors.grey[400] 
                  : const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
              icon: _isCreatingQuestion
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : const Icon(Icons.add_comment_rounded),
              label: Text(
                _isCreatingQuestion ? 'Mengirim...' : 'Tanya',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _selectedTab == 0
                ? 0
                : MediaQuery.of(context).size.width / 2 - 20,
            right: _selectedTab == 1
                ? 0
                : MediaQuery.of(context).size.width / 2 - 20,
            child: Container(
              margin: const EdgeInsets.all(4),
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(21),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildTabButton('Forum Diskusi', 0)),
              Expanded(child: _buildTabButton('Cari Mentor', 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _selectedTab == index ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildForumPage(List<ForumQuestion> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pertanyaan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama bertanya!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: _buildQuestionCard(q)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMentorPage(List<Mentor> mentors) {
    if (mentors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada mentor tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mentor akan segera hadir!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final m = mentors[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: _buildMentorCard(m)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(ForumQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                child: Icon(
                  question.isAnonymous
                      ? Icons.help_outline_rounded
                      : Icons.person_outline_rounded,
                  size: 18,
                  color: const Color(0xFFC7A500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.authorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                timeago.format(question.createdAt.toDate(), locale: 'id'),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            question.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${question.replyCount} balasan',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to question detail (implement later)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detail pertanyaan akan segera tersedia'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC7A500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(Mentor mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                    backgroundImage: mentor.profilePictureUrl.isNotEmpty
                        ? NetworkImage(mentor.profilePictureUrl)
                        : null,
                    child: mentor.profilePictureUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFFC7A500),
                          )
                        : null,
                  ),
                  if (mentor.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mentor.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFC7A500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mentor.isOnline 
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: mentor.isOnline 
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  mentor.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    color: mentor.isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mentor.bio,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (mentor.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mentor.skills.take(4)
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC7A500),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: mentor.isOnline ? () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memulai chat dengan ${mentor.name}'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                mentor.isOnline ? 'Mulai Chat' : 'Sedang Offline',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk membuat pertanyaan baru, sekarang terhubung dengan BLoC.
  void _showCreateQuestionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isAnonymous = true; // Default ke anonim

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Buat Pertanyaan Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Pertanyaan',
                        hintText: 'Tulis judul pertanyaan Anda...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Detail Pertanyaan',
                        hintText: 'Jelaskan pertanyaan Anda secara detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Kirim sebagai anonim'),
                      subtitle: const Text('Identitas Anda akan disembunyikan'),
                      value: isAnonymous,
                      onChanged: (value) =>
                          setModalState(() => isAnonymous = value),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFFFFD700),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreatingQuestion ? null : () {
                          // Validasi sederhana
                          if (titleController.text.trim().isNotEmpty &&
                              contentController.text.trim().isNotEmpty) {
                            // Memicu event BLoC untuk menambahkan pertanyaan
                            context.read<CommunityBloc>().add(
                              AddForumQuestion(
                                title: titleController.text.trim(),
                                content: contentController.text.trim(),
                                isAnonymous: isAnonymous,
                                // TODO: Get real user data from auth service
                                authorId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                                authorName: 'User Baru',
                              ),
                            );
                            Navigator.pop(dialogContext); // Tutup dialog
                          } else {
                            // Tampilkan pesan error jika form kosong
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Judul dan detail tidak boleh kosong!',
                                ),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCreatingQuestion 
                              ? Colors.grey[400] 
                              : const Color(0xFFFFD700),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isCreatingQuestion
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Mengirim...',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : const Text(
                                'Kirim Pertanyaan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}