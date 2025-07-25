import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/themes/theme.dart'; // Pastikan path ini benar

class ForumDetailPage extends StatefulWidget {
  // Data ini akan diterima dari halaman sebelumnya (halaman list forum)
  final String questionTitle;
  final String questionContent;
  final String author;
  final bool isAnonymous;

  const ForumDetailPage({
    super.key,
    required this.questionTitle,
    required this.questionContent,
    this.author = 'User123',
    this.isAnonymous = false,
  });

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _replyController = TextEditingController();

  // Dummy data untuk balasan
  final List<Map<String, dynamic>> replies = [
    {
      'author': 'Mbak Sarah (Mentor)',
      'content':
          'Pertanyaan bagus! Negosiasi gaji sebagai fresh graduate itu wajar kok. Kuncinya adalah riset standar gaji untuk posisimu dan tunjukkan value yang bisa kamu bawa ke perusahaan. Jangan takut, mereka sudah expect ini!',
      'isMentor': true,
      'likes': 15,
    },
    {
      'author': 'User456',
      'content':
          'Aku pernah coba nego dan berhasil naik 10% dari tawaran awal. Waktu itu aku bilang kalau aku punya skill X yang sesuai banget sama kebutuhan mereka.',
      'isMentor': false,
      'likes': 8,
    },
    {
      'author': 'Anonim',
      'content':
          'Sama, aku juga lagi di posisi ini. Thanks banget buat infonya!',
      'isMentor': false,
      'likes': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Detail Diskusi', style: AppTheme.subtitle1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Widget untuk menampilkan pertanyaan utama
                SliverToBoxAdapter(child: _buildQuestionHeader()),

                // Judul section untuk balasan
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      '${replies.length} Balasan',
                      style: AppTheme.h3,
                    ),
                  ),
                ),

                // List balasan dengan animasi
                _buildRepliesList(),
              ],
            ),
          ),
          // Input field untuk membalas
          _buildReplyInput(),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan header pertanyaan utama.
  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Icon(
                  widget.isAnonymous
                      ? Icons.help_outline_rounded
                      : Icons.person_outline_rounded,
                  color: AppTheme.primaryColorDark,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isAnonymous ? 'Anonim' : widget.author,
                    style: AppTheme.subtitle2,
                  ),
                  Text('2 jam yang lalu', style: AppTheme.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.questionTitle, style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(
            widget.questionContent,
            style: AppTheme.body1.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  /// Widget untuk membangun list balasan yang dianimasikan.
  Widget _buildRepliesList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final reply = replies[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildReplyCard(
                  author: reply['author'],
                  content: reply['content'],
                  isMentor: reply['isMentor'],
                  likes: reply['likes'],
                ),
              ),
            ),
          );
        }, childCount: replies.length),
      ),
    );
  }

  /// Widget untuk satu kartu balasan.
  Widget _buildReplyCard({
    required String author,
    required String content,
    required bool isMentor,
    required int likes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isMentor
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: isMentor
            ? Border.all(color: AppTheme.primaryColor, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(author, style: AppTheme.subtitle2),
              if (isMentor) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MENTOR',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTheme.body2.copyWith(color: AppTheme.textPrimaryColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 18,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text('$likes', style: AppTheme.caption),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget untuk input field balasan di bagian bawah.
  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Tulis balasanmu...',
                  fillColor: AppTheme.backgroundColor,
                  // Menggunakan InputDecorationTheme dari AppTheme
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Logika kirim balasan
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
