class ArticleProgress {
  static final Map<String, bool> _readArticles = {
    // Chapter 1 articles (already read for demo)
    'budget_bulanan': true,
    'tips_wawancara': true,

    // Chapter 2 articles (need to be read)
    'waspada_penipuan': false,
    'investasi_pemula': false,

    // Chapter 3 articles (locked)
    'cv_menarik': false,
    'networking_profesional': false,
    'menabung_efektif': false,
  };

  static final Map<String, int> _chapterProgress = {
    'chapter_1': 100, // Chapter 1 sudah selesai
    'chapter_2': 0, // Chapter 2 belum mulai
    'chapter_3': 0, // Chapter 3 locked
  };

  // Get read status
  static bool isArticleRead(String articleId) {
    return _readArticles[articleId] ?? false;
  }

  // Mark article as read
  static void markArticleAsRead(String articleId) {
    _readArticles[articleId] = true;
    _updateChapterProgress();
  }

  // Get all read articles
  static List<String> getReadArticles() {
    return _readArticles.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Check if required articles are read
  static bool areRequiredArticlesRead(List<String> requiredArticleIds) {
    return requiredArticleIds.every((id) => isArticleRead(id));
  }

  // Get read count for specific articles
  static int getReadCount(List<String> requiredArticleIds) {
    return requiredArticleIds.where((id) => isArticleRead(id)).length;
  }

  // Get chapter progress
  static int getChapterProgress(String chapterId) {
    return _chapterProgress[chapterId] ?? 0;
  }

  // Check if chapter is unlocked
  static bool isChapterUnlocked(String chapterId) {
    switch (chapterId) {
      case 'chapter_1':
        return true; // Always unlocked
      case 'chapter_2':
        // Unlock if Chapter 1 is complete and required articles are read
        return _chapterProgress['chapter_1'] == 100 &&
            areRequiredArticlesRead(['waspada_penipuan', 'budget_bulanan']);
      case 'chapter_3':
        // Unlock if Chapter 2 is complete
        return _chapterProgress['chapter_2'] == 100;
      default:
        return false;
    }
  }

  // Update chapter progress based on read articles
  static void _updateChapterProgress() {
    // Chapter 2 progress calculation
    final chapter2Required = ['waspada_penipuan', 'budget_bulanan'];
    final chapter2ReadCount = getReadCount(chapter2Required);
    if (chapter2ReadCount == chapter2Required.length) {
      _chapterProgress['chapter_2'] = 50; // Ready to start adventure
    }

    // Add more chapter progress logic here
  }

  // Complete chapter (call this when adventure is finished)
  static void completeChapter(String chapterId) {
    _chapterProgress[chapterId] = 100;
  }

  // Get current active chapter
  static String getCurrentChapter() {
    if (_chapterProgress['chapter_1'] == 100 &&
        !isChapterUnlocked('chapter_2')) {
      return 'chapter_2_preparation';
    } else if (isChapterUnlocked('chapter_2') &&
        (_chapterProgress['chapter_2'] ?? 0) < 100) {
      return 'chapter_2';
    } else if (isChapterUnlocked('chapter_3')) {
      return 'chapter_3';
    }
    return 'chapter_1';
  }

  // Get required articles for current chapter
  static List<String> getRequiredArticlesForCurrentChapter() {
    final currentChapter = getCurrentChapter();
    switch (currentChapter) {
      case 'chapter_2_preparation':
      case 'chapter_2':
        return ['waspada_penipuan', 'budget_bulanan'];
      case 'chapter_3':
        return ['cv_menarik', 'networking_profesional'];
      default:
        return [];
    }
  }
}
