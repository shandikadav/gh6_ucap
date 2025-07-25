import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/community_model.dart';
import '../../services/community_service.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _communityRepository;

  CommunityBloc({required CommunityRepository communityRepository})
    : _communityRepository = communityRepository,
      super(CommunityInitial()) {
    on<FetchCommunityData>(_onFetchCommunityData);
    on<AddForumQuestion>(_onAddForumQuestion);
    on<RefreshCommunityData>(_onRefreshCommunityData); // Event baru untuk refresh
  }

  Future<void> _onFetchCommunityData(
    FetchCommunityData event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      final results = await Future.wait([
        _communityRepository.fetchForumQuestions(),
        _communityRepository.fetchMentors(),
      ]);
      final questions = results[0] as List<ForumQuestion>;
      final mentors = results[1] as List<Mentor>;
      emit(CommunityLoaded(questions: questions, mentors: mentors));
    } catch (e) {
      print('Error in _onFetchCommunityData: $e');
      emit(CommunityError(message: 'Gagal memuat data komunitas: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshCommunityData(
    RefreshCommunityData event,
    Emitter<CommunityState> emit,
  ) async {
    // Tidak emit loading untuk refresh, biar UX lebih smooth
    try {
      final results = await Future.wait([
        _communityRepository.fetchForumQuestions(),
        _communityRepository.fetchMentors(),
      ]);
      final questions = results[0] as List<ForumQuestion>;
      final mentors = results[1] as List<Mentor>;
      emit(CommunityLoaded(questions: questions, mentors: mentors));
    } catch (e) {
      print('Error in _onRefreshCommunityData: $e');
      // Jika refresh gagal, tetap emit error tapi dengan pesan yang berbeda
      emit(CommunityError(message: 'Gagal memuat ulang data: ${e.toString()}'));
    }
  }

  /// HANDLER BARU: Untuk event AddForumQuestion.
  Future<void> _onAddForumQuestion(
    AddForumQuestion event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Emit state loading dengan data sebelumnya jika ada
      if (state is CommunityLoaded) {
        final currentState = state as CommunityLoaded;
        emit(CommunityCreatingQuestion(
          questions: currentState.questions,
          mentors: currentState.mentors,
        ));
      } else {
        emit(CommunityLoading());
      }

      await _communityRepository.createForumQuestion(
        title: event.title,
        content: event.content,
        authorId: event.authorId,
        authorName: event.authorName,
        isAnonymous: event.isAnonymous,
      );
      
      // Emit success state
      emit(CommunityQuestionCreated());
      
      // Refresh data setelah berhasil create
      add(RefreshCommunityData());
    } catch (e) {
      print('Error in _onAddForumQuestion: $e');
      emit(CommunityError(message: 'Gagal mengirim pertanyaan: ${e.toString()}'));
    }
  }
}