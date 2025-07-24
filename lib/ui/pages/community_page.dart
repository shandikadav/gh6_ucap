import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Perubahan 1: Menggunakan PageController untuk swipe antar halaman
  late PageController _pageController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
    // Animasikan PageView saat tab di-tap
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
      // Perubahan 2: AppBar dibuat minimalis dan menyatu dengan background
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
          // Perubahan 3: Custom Tab Bar yang lebih modern
          _buildCustomTabBar(),
          // Perubahan 4: Menggunakan PageView untuk konten yang bisa di-swipe
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              children: [_buildForumPage(), _buildMentorPage()],
            ),
          ),
          SizedBox(height: 100.r),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showCreateQuestionDialog(context);
              },
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text(
                'Tanya',
                style: TextStyle(fontWeight: FontWeight.bold),
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
          // Perubahan 5: Indikator yang bergeser dengan animasi
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
        color: Colors.transparent, // Membuat area tap transparan
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

  // Konten Forum dipisah menjadi method sendiri
  Widget _buildForumPage() {
    // Dummy data untuk forum
    final questions = [
      {
        'title': 'Bagaimana cara negosiasi gaji saat fresh graduate?',
        'content':
            'Aku baru lulus dan dapat tawaran kerja. Tapi gajinya di bawah ekspektasi. Boleh ga sih nego gaji? Takut malah ditolak...',
        'replies': 12,
        'isAnonymous': true,
      },
      {
        'title': 'Tips menghadapi diskriminasi di tempat kerja?',
        'content':
            'Ada yang pernah ngalamin diperlakukan beda karena background kita? Gimana cara ngatasinya ya?',
        'replies': 8,
        'isAnonymous': true,
      },
      {
        'title': 'Rekomendasi tempat kos yang aman dan murah?',
        'content':
            'Lagi cari kos di area Jakarta Selatan budget 1-1.5 juta. Ada yang punya rekomendasi?',
        'replies': 15,
        'isAnonymous': false,
      },
    ];

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
              child: FadeInAnimation(
                child: _buildQuestionCard(
                  q['title'] as String,
                  q['content'] as String,
                  q['replies'] as int,
                  q['isAnonymous'] as bool,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Konten Mentor dipisah menjadi method sendiri
  Widget _buildMentorPage() {
    // Dummy data untuk mentor
    final mentors = [
      {
        'name': 'Budi Santoso',
        'title': 'Mentor Karier',
        'bio': 'HR Manager dengan 10+ tahun pengalaman',
        'isOnline': true,
        'skills': ['Review CV', 'Interview'],
      },
      {
        'name': 'Sarah Wijaya',
        'title': 'Konselor Keuangan',
        'bio': 'Financial Planner bersertifikat CFP',
        'isOnline': false,
        'skills': ['Budgeting', 'Investasi'],
      },
      {
        'name': 'Rendi Pratama',
        'title': 'Mentor Soft Skills',
        'bio': 'Corporate Trainer & Life Coach',
        'isOnline': true,
        'skills': ['Komunikasi', 'Leadership'],
      },
    ];

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
              child: FadeInAnimation(
                child: _buildMentorCard(
                  m['name'] as String,
                  m['title'] as String,
                  m['bio'] as String,
                  m['isOnline'] as bool,
                  m['skills'] as List<String>,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Desain kartu pertanyaan sedikit di-tweak
  Widget _buildQuestionCard(
    String title,
    String content,
    int replies,
    bool isAnonymous,
  ) {
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
                  isAnonymous
                      ? Icons.help_outline_rounded
                      : Icons.person_outline_rounded,
                  size: 18,
                  color: const Color(0xFFC7A500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAnonymous ? 'Anonim' : 'User123',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                '2 jam yang lalu',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
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
                '$replies balasan',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  
                },
                child: Text(
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

  // Desain kartu mentor sedikit di-tweak
  Widget _buildMentorCard(
    String name,
    String title,
    String bio,
    bool isOnline,
    List<String> skills,
  ) {
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
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFFC7A500),
                    ),
                  ),
                  if (isOnline)
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
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFC7A500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
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
              ElevatedButton(
                onPressed: () => HapticFeedback.lightImpact(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Chat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog tidak banyak berubah, hanya styling
  void _showCreateQuestionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
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
                decoration: InputDecoration(
                  labelText: 'Judul Pertanyaan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Detail Pertanyaan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Kirim sebagai anonim'),
                value: true,
                onChanged: (value) {},
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: Color(0xFFFFD700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim Pertanyaan',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
