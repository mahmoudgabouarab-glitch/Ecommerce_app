part of 'genie_cubit.dart';

class GenieState {
  final List<GenieMessage> messages;
  final bool sending;

  const GenieState({this.messages = const [], this.sending = false});

  GenieState copyWith({List<GenieMessage>? messages, bool? sending}) {
    return GenieState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
    );
  }
}
