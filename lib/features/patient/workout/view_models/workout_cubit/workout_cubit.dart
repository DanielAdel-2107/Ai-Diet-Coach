import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_diet_coach/features/patient/workout/models/exercise_model.dart';
import 'package:ai_diet_coach/features/patient/workout/view_models/workout_cubit/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  WorkoutCubit() : super(WorkoutInitial());

  List<ExerciseModel> _allExercises = [];
  List<String> _categories = ["All"];

  Future<void> loadWorkouts() async {
    emit(WorkoutLoading());
    try {
      final List<dynamic> data = await _supabase.from('workouts').select();
      
      _allExercises = data
          .map((json) => ExerciseModel.fromJson(json))
          .toList();

      // Extract distinct dynamic body parts and format them nicely
      final Set<String> bodyParts = _allExercises
          .where((e) => e.bodyPart.isNotEmpty)
          .map((e) => _capitalize(e.bodyPart))
          .toSet();
      
      _categories = ["All", ...bodyParts.toList()..sort()];

      emit(WorkoutLoaded(List.from(_allExercises), "All", _categories));
    } catch (e) {
      emit(WorkoutFailure(e.toString()));
    }
  }

  void filterByCategory(String category) {
    if (state is WorkoutLoaded || state is WorkoutFailure) {
      if (category == "All") {
        emit(WorkoutLoaded(List.from(_allExercises), category, _categories));
      } else {
        final filteredList = _allExercises
            .where((e) => _capitalize(e.bodyPart) == category)
            .toList();
        emit(WorkoutLoaded(filteredList, category, _categories));
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
