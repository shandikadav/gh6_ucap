import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gh6_ucap/services/forum_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumDetailPage extends StatefulWidget {
  final String questionId;
  final String questionTitle;
  final String questionContent;
  final String author;
  final bool isAnonymous;
  final String authorId;
  final Timestamp createdAt;

  const ForumDetailPage({
    super.key,
    required this.questionId,
    required this.questionTitle,
    required this.questionContent,
    required this.author,
    required this.isAnonymous,
    required this.authorId,
    required this.createdAt,
  });

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  final ForumService _forumService = ForumService();
  final FocusNode _replyFocusNode = FocusNode();
  
  bool _isAnonymousReply = true;
  bool _isLoadingReply = false;
  String _currentUserName = 'User';

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final userData = await _forumService.getCurrentUserData();
    if (userData != null && mounted) {
      setState(() {
        _currentUserName = userData['fullname'] ?? 'User';
      });
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Balasan tidak boleh kosong!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoadingReply = true);

    try {
      await _forumService.addReply(
        questionId: widget.questionId,
        content: _replyController.text.trim(),
        isAnonymous: _isAnonymousReply,
      );

      _replyController.clear();
      _replyFocusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Balasan berhasil dikirim!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim balasan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingReply = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5EE),
        elevation: 0,
        title: Text(
          'Detail Diskusi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Question Header
                SliverToBoxAdapter(child: _buildQuestionHeader()),

                // Replies Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                    child: StreamBuilder<List<ForumReply>>(
                      stream: _forumService.getReplies(widget.questionId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading replies',
                            style: TextStyle(color: Colors.red, fontSize: 14.sp),
                          );
                        }

                        final replyCount = snapshot.hasData ? snapshot.data!.length : 0;
                        return Text(
                          '$replyCount Balasan',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Replies List
                StreamBuilder<List<ForumReply>>(
                  stream: _forumService.getReplies(widget.questionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: CircularProgressIndicator(
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Gagal memuat balasan',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final replies = snapshot.data ?? [];

                    if (replies.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Belum ada balasan',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Jadilah yang pertama memberikan balasan!',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reply = replies[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildReplyCard(reply),
                                ),
                              ),
                            );
                          },
                          childCount: replies.length,
                        ),
                      ),
                    );
                  },
                ),

                // Bottom spacing
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),

          // Reply Input
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
                radius: 20.r,
                backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                child: Icon(
                  widget.isAnonymous
                      ? Icons.help_outline_rounded
                      : Icons.person_outline_rounded,
                  color: const Color(0xFFC7A500),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAnonymous ? 'Anonim' : widget.author,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      timeago.format(widget.createdAt.toDate(), locale: 'id'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.questionTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.questionContent,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(ForumReply reply) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLikedByCurrentUser = currentUser != null && 
        reply.likedBy.contains(currentUser.uid);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                radius: 16.r,
                backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                child: Icon(
                  reply.isAnonymous
                      ? Icons.help_outline_rounded
                      : Icons.person_outline_rounded,
                  color: const Color(0xFFC7A500),
                  size: 16.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.authorName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      timeago.format(reply.createdAt.toDate(), locale: 'id'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (reply.isEdited)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Diedit',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            reply.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              InkWell(
                onTap: currentUser != null ? () async {
                  HapticFeedback.lightImpact();
                  try {
                    await _forumService.toggleReplyLike(
                      widget.questionId,
                      reply.id,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }
                } : null,
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLikedByCurrentUser
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18.w,
                        color: isLikedByCurrentUser
                            ? Colors.red
                            : Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${reply.likes}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anonymous toggle
            Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 16.w,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  'Kirim sebagai anonim',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _isAnonymousReply,
                  onChanged: (value) {
                    setState(() => _isAnonymousReply = value);
                  },
                  activeColor: const Color(0xFFFFD700),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            // Preview of name
            Text(
              'Tampil sebagai: ${_isAnonymousReply ? "Anonim" : _currentUserName}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    focusNode: _replyFocusNode,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Tulis balasanmu...',
                      fillColor: const Color(0xFFF8F5EE),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _isLoadingReply ? null : _submitReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16.w),
                    elevation: 0,
                  ),
                  child: _isLoadingReply
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 20.w,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}