import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/stats_model.dart';
import '../../../data/repo/admin_repo.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit(this._repo) : super(StatsInitial());

  final AdminRepo _repo;

  Future<void> getStats() async {
    emit(StatsLoading());
    final result = await _repo.getStats();
    result.fold(
      (failure) => emit(StatsFailure(failure.errorMessage)),
      (stats) => emit(StatsSuccess(stats)),
    );
  }
}
