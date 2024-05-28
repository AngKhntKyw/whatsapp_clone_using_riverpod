class Group {
  final String groupName;
  final String groupId;
  final String groupPicture;
  final String lastMessage;
  final String messageSenderId;
  final List<String> membersId;
  final DateTime timeSent;
  Group({
    required this.groupName,
    required this.groupId,
    required this.groupPicture,
    required this.lastMessage,
    required this.messageSenderId,
    required this.membersId,
    required this.timeSent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupName': groupName,
      'groupId': groupId,
      'groupPicture': groupPicture,
      'lastMessage': lastMessage,
      'messageSenderId': messageSenderId,
      'membersId': membersId,
      'timeSent': timeSent.millisecondsSinceEpoch,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupName: map['groupName'] ?? '',
      groupId: map['groupId'] ?? '',
      groupPicture: map['groupPicture'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      messageSenderId: map['messageSenderId'] ?? '',
      membersId: List<String>.from(map['membersId']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
    );
  }
}
