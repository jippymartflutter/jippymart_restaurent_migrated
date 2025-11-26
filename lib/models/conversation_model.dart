import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? orderId;
  String? message;
  String? messageType;
  String? videoThumbnail;
  Url? url;
  Timestamp? createdAt;
  String? chatId; // Added missing field

  ConversationModel({
    this.id,
    this.senderId,
    this.receiverId,
    this.orderId,
    this.message,
    this.messageType,
    this.videoThumbnail,
    this.url,
    this.createdAt,
    this.chatId, // Added missing field
  });

  factory ConversationModel.fromJsonApi(Map<String, dynamic> json) {
    // Handle createdAt conversion from String to Timestamp
    Timestamp? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        // Convert ISO string to DateTime then to Timestamp
        try {
          final dateTime = DateTime.parse(json['createdAt']).toLocal();
          createdAt = Timestamp.fromDate(dateTime);
        } catch (e) {
          createdAt = Timestamp.now();
        }
      } else if (json['createdAt'] is Timestamp) {
        createdAt = json['createdAt'];
      }
    }

    // Handle URL parsing safely
    Url? url;
    if (json['url'] != null && json['url'] != 'null') {
      if (json['url'] is Map<String, dynamic>) {
        url = Url.fromJson(json['url']);
      } else if (json['url'] is String) {
        // If URL is just a string, create a basic Url object
        url = Url(url: json['url'], mime: _getMimeTypeFromUrl(json['url']));
      }
    }

    return ConversationModel(
      id: json['id']?.toString(),
      message: json['message']?.toString(),
      senderId: json['senderId']?.toString(),
      receiverId: json['receiverId']?.toString(),
      createdAt: createdAt ?? Timestamp.now(),
      url: url,
      orderId: json['orderId']?.toString(),
      messageType: json['messageType']?.toString(),
      videoThumbnail: json['videoThumbnail']?.toString(),
      chatId: json['chat_id']?.toString(),
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> parsedJson) {
    return ConversationModel(
      id: parsedJson['id']?.toString() ?? '',
      senderId: parsedJson['senderId']?.toString() ?? '',
      receiverId: parsedJson['receiverId']?.toString() ?? '',
      orderId: parsedJson['orderId']?.toString() ?? '',
      message: parsedJson['message']?.toString() ?? '',
      messageType: parsedJson['messageType']?.toString() ?? '',
      videoThumbnail: parsedJson['videoThumbnail']?.toString() ?? '',
      url: parsedJson.containsKey('url') && parsedJson['url'] != null
          ? Url.fromJson(parsedJson['url'] is Map<String, dynamic>
          ? parsedJson['url']
          : {'url': parsedJson['url']?.toString() ?? ''})
          : null,
      createdAt: parsedJson['createdAt'] ?? Timestamp.now(),
      chatId: parsedJson['chat_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'orderId': orderId,
      'message': message,
      'messageType': messageType,
      'videoThumbnail': videoThumbnail,
      'url': url?.toJson(),
      'createdAt': createdAt,
      'chat_id': chatId,
    };
  }

  // Helper method to determine mime type from URL
  static String _getMimeTypeFromUrl(String url) {
    if (url.toLowerCase().contains('.jpg') ||
        url.toLowerCase().contains('.jpeg') ||
        url.toLowerCase().contains('.png') ||
        url.toLowerCase().contains('.gif')) {
      return 'image';
    } else if (url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.toLowerCase().contains('.avi')) {
      return 'video';
    } else if (url.toLowerCase().contains('.mp3') ||
        url.toLowerCase().contains('.wav')) {
      return 'audio';
    }
    return 'unknown';
  }
}

class Url {
  String mime;
  String url;
  String? videoThumbnail;

  Url({this.mime = '', this.url = '', this.videoThumbnail});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(
        mime: parsedJson['mime']?.toString() ?? '',
        url: parsedJson['url']?.toString() ?? '',
        videoThumbnail: parsedJson['videoThumbnail']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mime': mime,
      'url': url,
      'videoThumbnail': videoThumbnail
    };
  }
}