import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/review_model.dart';
import '../../../data/repo/home_repo.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._repo) : super(ReviewsInitial());

  final HomeRepo _repo;

  Future<void> getReviews(int productId) async {
    emit(ReviewsLoading());
    final result = await _repo.getReviews(productId);
    result.fold(
      (failure) => emit(ReviewsFailure(failure.errorMessage)),
      (reviews) => emit(ReviewsSuccess(reviews)),
    );
  }

  Future<void> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    emit(ReviewSubmitting());
    final result = await _repo.addReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
    result.fold(
      (failure) => emit(ReviewsFailure(failure.errorMessage)),
      (_) {
        emit(ReviewSubmitted());
        getReviews(productId); // refresh list
      },
    );
  }
}
