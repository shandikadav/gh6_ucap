import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ScenarioData {
  final String id;
  final String title;
  final String category;
  final String tag;
  final String iconName;
  final String colorHex;
  final int requiredExp;
  final int requiredLevel;
  final bool isActive;
  final List<ScenarioStepData> steps;
  final int rewardExp;
  final String difficulty;
  final int estimatedTime; // in minutes
  final List<String> learningOutcomes;

  ScenarioData({
    required this.id,
    required this.title,
    required this.category,
    required this.tag,
    required this.iconName,
    required this.colorHex,
    required this.requiredExp,
    required this.requiredLevel,
    required this.isActive,
    required this.steps,
    required this.rewardExp,
    required this.difficulty,
    required this.estimatedTime,
    required this.learningOutcomes,
  });

  factory ScenarioData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScenarioData(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      tag: data['tag'] ?? '',
      iconName: data['iconName'] ?? 'work',
      colorHex: data['colorHex'] ?? '#FFD700',
      requiredExp: data['requiredExp'] ?? 0,
      requiredLevel: data['requiredLevel'] ?? 1,
      isActive: data['isActive'] ?? true,
      rewardExp: data['rewardExp'] ?? 50,
      difficulty: data['difficulty'] ?? 'Beginner',
      estimatedTime: data['estimatedTime'] ?? 15,
      learningOutcomes: List<String>.from(data['learningOutcomes'] ?? []),
      steps: (data['steps'] as List<dynamic>?)
          ?.map((step) => ScenarioStepData.fromMap(step))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'tag': tag,
      'iconName': iconName,
      'colorHex': colorHex,
      'requiredExp': requiredExp,
      'requiredLevel': requiredLevel,
      'isActive': isActive,
      'rewardExp': rewardExp,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
      'learningOutcomes': learningOutcomes,
      'steps': steps.map((step) => step.toMap()).toList(),
    };
  }

  bool isUnlocked(int userExp, int userLevel) {
    return userExp >= requiredExp && userLevel >= requiredLevel;
  }
}

class ScenarioStepData {
  final String story;
  final String characterEmoji;
  final String characterAlignment; // 'center', 'left', 'right'
  final List<ScenarioChoiceData>? choices;
  final bool isEndStep;

  ScenarioStepData({
    required this.story,
    required this.characterEmoji,
    required this.characterAlignment,
    this.choices,
    this.isEndStep = false,
  });

  factory ScenarioStepData.fromMap(Map<String, dynamic> data) {
    return ScenarioStepData(
      story: data['story'] ?? '',
      characterEmoji: data['characterEmoji'] ?? '😊',
      characterAlignment: data['characterAlignment'] ?? 'center',
      isEndStep: data['isEndStep'] ?? false,
      choices: (data['choices'] as List<dynamic>?)
          ?.map((choice) => ScenarioChoiceData.fromMap(choice))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'story': story,
      'characterEmoji': characterEmoji,
      'characterAlignment': characterAlignment,
      'isEndStep': isEndStep,
      'choices': choices?.map((choice) => choice.toMap()).toList(),
    };
  }

  Alignment get alignment {
    switch (characterAlignment) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}

class ScenarioChoiceData {
  final String text;
  final String emoji;
  final bool isCorrect;
  final String feedback;
  final String reason;
  final int expModifier; // bonus/penalty exp

  ScenarioChoiceData({
    required this.text,
    required this.emoji,
    required this.isCorrect,
    required this.feedback,
    required this.reason,
    this.expModifier = 0,
  });

  factory ScenarioChoiceData.fromMap(Map<String, dynamic> data) {
    return ScenarioChoiceData(
      text: data['text'] ?? '',
      emoji: data['emoji'] ?? '🤔',
      isCorrect: data['isCorrect'] ?? false,
      feedback: data['feedback'] ?? '',
      reason: data['reason'] ?? '',
      expModifier: data['expModifier'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'emoji': emoji,
      'isCorrect': isCorrect,
      'feedback': feedback,
      'reason': reason,
      'expModifier': expModifier,
    };
  }
}