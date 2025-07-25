import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/themes/theme.dart';
import 'package:gh6_ucap/services/article_service.dart';

class MaterialDetailPage extends StatefulWidget {
  final String articleId;
  final String materialTitle;
  final String materialContent;
  final String materialType;
  final int expGained;
  final VoidCallback onComplete;

  const MaterialDetailPage({
    super.key,
    required this.articleId,
    required this.materialTitle,
    required this.materialContent,
    required this.materialType,
    required this.expGained,
    required this.onComplete,
  });

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  final ArticleService _articleService = ArticleService();
  bool hasCompleted = false;
  bool isAlreadyCompleted = false;
  final ScrollController _scrollController = ScrollController();
  bool showCompleteButton = false;
  double readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _checkIfAlreadyCompleted();
    print('🔍 Article ID: ${widget.articleId}');
    print('🔍 Material Type: ${widget.materialType}');
    print('🔍 EXP Reward: ${widget.expGained}');
  }

  Future<void> _checkIfAlreadyCompleted() async {
    try {
      final completedArticles = await _articleService
          .getUserCompletedArticles();
      if (mounted) {
        setState(() {
          isAlreadyCompleted = completedArticles.contains(widget.articleId);
          if (isAlreadyCompleted) {
            showCompleteButton = false;
            hasCompleted = true;
          }
        });
      }
    } catch (e) {
      print('Error checking completion status: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (maxScroll > 0) {
        final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        setState(() {
          readingProgress = progress;
        });

        // Show complete button when user scrolls to 70% of content
        if (progress >= 0.7 && !showCompleteButton && !isAlreadyCompleted) {
          setState(() {
            showCompleteButton = true;
          });
        }
      }
    }
  }

  Future<void> _completeArticle() async {
    if (!hasCompleted && !isAlreadyCompleted) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );

        // Complete the article
        await _articleService.completeArticle(widget.articleId);

        // Update state
        setState(() {
          hasCompleted = true;
          isAlreadyCompleted = true;
        });

        // Call parent callback
        widget.onComplete();

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success dialog
        _showSuccessDialog();
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyelesaikan artikel: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                color: Colors.amber[700],
                size: 32.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Selamat!',
              style: AppTheme.h3.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kamu telah menyelesaikan artikel:',
              style: AppTheme.body2.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                '"${widget.materialTitle}"',
                style: AppTheme.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColorDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.8), Colors.amber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: Colors.white, size: 24.w),
                  SizedBox(width: 8.w),
                  Text(
                    '+${widget.expGained} EXP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to category
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Lanjutkan Belajar',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom AppBar dengan gradient
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Article Type Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.article,
                                color: Colors.white,
                                size: 16.w,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Artikel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Title
                        Text(
                          widget.materialTitle,
                          style: AppTheme.h2.copyWith(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),

                        // EXP Info
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Colors.white,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '+${widget.expGained} EXP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            ),
                            if (isAlreadyCompleted) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Selesai',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Progress indicator
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.h),
              child: SizedBox(
                height: 4.h,
                child: LinearProgressIndicator(
                  value: readingProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                children: [
                  // Content Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    child: Markdown(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      data: widget.materialContent,
                      styleSheet: MarkdownStyleSheet(
                        h1: AppTheme.h2.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          height: 1.4,
                        ),
                        h2: AppTheme.h3.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColorDark,
                          height: 1.4,
                        ),
                        h3: AppTheme.subtitle1.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                          height: 1.4,
                        ),
                        p: AppTheme.body1.copyWith(
                          height: 1.8,
                          fontSize: 16.sp,
                          color: AppTheme.textPrimaryColor,
                        ),
                        listBullet: AppTheme.body1.copyWith(
                          fontSize: 16.sp,
                          height: 1.6,
                          color: AppTheme.textPrimaryColor,
                        ),
                        code: AppTheme.body1.copyWith(
                          backgroundColor: Colors.grey.shade200,
                          fontFamily: 'monospace',
                          fontSize: 14.sp,
                          color: AppTheme.primaryColorDark,
                        ),
                        blockquote: AppTheme.body1.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                          fontSize: 16.sp,
                          height: 1.6,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 4.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Complete Button Section
                  if (showCompleteButton &&
                      !hasCompleted &&
                      !isAlreadyCompleted)
                    Container(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.1),
                                  Colors.green.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 48.w,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Selesai membaca?',
                                  style: AppTheme.h3.copyWith(
                                    color: Colors.green[700],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Klik tombol di bawah untuk menyelesaikan artikel dan mendapat EXP',
                                  style: AppTheme.body2.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _completeArticle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 18.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 4,
                              ),
                              icon: Icon(Icons.check_circle, size: 24.w),
                              label: Text(
                                'Selesai Baca (+${widget.expGained} EXP)',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),

                  // Already Completed Status
                  if (isAlreadyCompleted)
                    Container(
                      margin: EdgeInsets.all(24.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48.w,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Artikel Selesai!',
                            style: AppTheme.h3.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Kamu sudah menyelesaikan artikel ini dan mendapat +${widget.expGained} EXP',
                            style: AppTheme.body2.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  // Bottom padding
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
