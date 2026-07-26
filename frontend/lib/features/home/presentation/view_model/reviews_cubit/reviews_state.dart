part of 'reviews_cubit.dart';

sealed class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object> get props => [];
}

final class ReviewsInitial extends ReviewsState {}

final class ReviewsLoading extends ReviewsState {}

final class ReviewSubmitting extends ReviewsState {}

final class ReviewSubmitted extends ReviewsState {}

final class ReviewsSuccess extends ReviewsState {
  final List<ReviewModel> reviews;
  const ReviewsSuccess(this.reviews);

  @override
  List<Object> get props => [reviews];
}

final class ReviewsFailure extends ReviewsState {
  final String error;
  const ReviewsFailure(this.error);

  @override
  List<Object> get props => [error];
}
