import 'location.dart';

enum ChatRole { user, assistant }

/// One message in a Tanya Loka conversation.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.locations = const [],
  });

  final ChatRole role;
  final String text;

  /// Places the answer refers to, shown as tappable chips.
  final List<Location> locations;
}
