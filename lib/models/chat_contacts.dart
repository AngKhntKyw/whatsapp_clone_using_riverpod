class ChatContacts {
  final String name;
  final String profilePicture;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;

  const ChatContacts({
    required this.name,
    required this.profilePicture,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
  });

  ChatContacts copyWith({
    String? name,
    String? profilePicture,
    String? contactId,
    DateTime? timeSent,
    String? lastMessage,
  }) {
    return ChatContacts(
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      contactId: contactId ?? this.contactId,
      timeSent: timeSent ?? this.timeSent,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePicture': profilePicture,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  factory ChatContacts.fromMap(Map<String, dynamic> map) {
    return ChatContacts(
      name: map['name'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      lastMessage: map['lastMessage'] ?? '',
    );
  }
}
