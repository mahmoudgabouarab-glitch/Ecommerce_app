import 'genie_product.dart';

enum GenieRole { user, assistant }

class GenieMessage {
  final GenieRole role;
  final String content;
  final List<GenieProduct> products;

  const GenieMessage({
    required this.role,
    required this.content,
    this.products = const [],
  });

  Map<String, String> toApi() => {
        'role': role == GenieRole.user ? 'user' : 'assistant',
        'content': content,
      };
}

class GenieReply {
  final String reply;
  final List<GenieProduct> products;

  const GenieReply({required this.reply, required this.products});

  factory GenieReply.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List<dynamic>? ?? [])
        .map((e) => GenieProduct.fromJson(e as Map<String, dynamic>))
        .toList();
    return GenieReply(
      reply: json['reply'] as String? ?? '',
      products: list,
    );
  }
}
