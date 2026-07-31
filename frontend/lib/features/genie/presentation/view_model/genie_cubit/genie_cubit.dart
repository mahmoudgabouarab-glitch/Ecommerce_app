import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/genie_message.dart';
import '../../../data/repo/genie_repo.dart';

part 'genie_state.dart';

class GenieCubit extends Cubit<GenieState> {
  final GenieRepo _repo;

  GenieCubit(this._repo) : super(const GenieState());

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    final history = [
      ...state.messages,
      GenieMessage(role: GenieRole.user, content: trimmed),
    ];
    emit(state.copyWith(messages: history, sending: true));

    final payload = history.map((m) => m.toApi()).toList();
    final result = await _repo.chat(payload);

    result.fold(
      (failure) => emit(state.copyWith(
        sending: false,
        messages: [
          ...state.messages,
          GenieMessage(
            role: GenieRole.assistant,
            content: failure.errorMessage,
          ),
        ],
      )),
      (reply) => emit(state.copyWith(
        sending: false,
        messages: [
          ...state.messages,
          GenieMessage(
            role: GenieRole.assistant,
            content: reply.reply,
            products: reply.products,
          ),
        ],
      )),
    );
  }
}
