import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';

class UserModel {
  String? id;
  String? firstName;
  String?firebaseId;
  String? lastName;
  String? email;
  String? profilePictureURL;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  num? walletAmount;
  bool? active;
  bool? isActive;
  bool? isDocumentVerify;
  Timestamp? createdAt;
  String? role;
  UserLocation? location;
  UserBankDetails? userBankDetails;
  List<ShippingAddress>? shippingAddress;
  String? carName;
  String? carNumber;
  String? carPictureURL;
  List<dynamic>? inProgressOrderID;
  List<dynamic>? orderRequestData;
  String? vendorID;
  String? zoneId;
  num? rotation;
  String? appIdentifier;
  String? provider;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;

  UserModel(
      {this.id,
      this.firstName,
        this.firebaseId,
      this.lastName,
      this.active,
      this.isActive,
      this.isDocumentVerify,
      this.email,
      this.profilePictureURL,
      this.fcmToken,
      this.countryCode,
      this.phoneNumber,
      this.walletAmount,
      this.createdAt,
      this.role,
      this.location,
      this.shippingAddress,
      this.carName,
      this.carNumber,
      this.carPictureURL,
      this.inProgressOrderID,
      this.orderRequestData,
      this.vendorID,
      this.zoneId,
      this.rotation,
      this.appIdentifier,
      this.provider,
      this.subscriptionPlanId,
      this.subscriptionExpiryDate,
      this.subscriptionPlan});

  fullName() {
    return "${firstName ?? ''} ${lastName ?? ''}";
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    // Handle id field: convert int to String if needed
    if (json['id'] != null) {
      if (json['id'] is int) {
        id = json['id'].toString();
      } else if (json['id'] is String) {
        id = json['id'];
      } else {
        id = json['id']?.toString();
      }
    } else {
      id = null;
    }

    zoneId = json['zoneId'] ?? '';
    email = json['email'];
    firstName = json['firstName'];
    firebaseId = json['firebase_id'];
    lastName = json['lastName'];
    profilePictureURL = json['profilePictureURL'] ?? json['profile_pic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phone'] ?? json['phoneNumber'];

    // Handle wallet_amount for both int and double values
    if (json['wallet_amount'] != null) {
      if (json['wallet_amount'] is int) {
        walletAmount = json['wallet_amount'].toDouble();
      } else if (json['wallet_amount'] is double) {
        walletAmount = json['wallet_amount'];
      } else if (json['wallet_amount'] is String) {
        walletAmount = double.tryParse(json['wallet_amount']) ?? 0;
      } else {
        walletAmount = 0;
      }
    } else {
      walletAmount = 0;
    }

    // Handle createdAt safely
    createdAt = _parseTimestamp(json['createdAt'] ?? json['_created_at']);

    // Handle boolean conversions safely
    active = _parseBool(json['active']);
    isActive = _parseBool(json['isActive']);
    isDocumentVerify = _parseBool(json['isDocumentVerify']);

    role = json['role'] ?? 'user';
    location = json['location'] != null
        ? UserLocation.fromJson(json['location'])
        : null;
    try {
      if (json['userBankDetails'] != null && json['userBankDetails'] is Map) {
        userBankDetails = UserBankDetails.fromJson(json['userBankDetails'] as Map<String, dynamic>);
      } else {
        userBankDetails = null;
      }
    } catch (e) {
      print('Error parsing userBankDetails: $e');
      userBankDetails = null;
    }
    // FIX: Handle shippingAddress with better error handling
    shippingAddress = _parseShippingAddress(json['shippingAddress']);

    carName = json['carName'];
    carNumber = json['carNumber'];
    carPictureURL = json['carPictureURL'];
    inProgressOrderID = json['inProgressOrderID'];
    orderRequestData = json['orderRequestData'];
    vendorID = json['vendorID'] ?? '';

    // Handle rotation field: convert String to num if needed
    if (json['rotation'] != null) {
      if (json['rotation'] is num) {
        rotation = json['rotation'];
      } else if (json['rotation'] is String) {
        rotation = num.tryParse(json['rotation']) ?? 0;
      }
    }
    appIdentifier = json['appIdentifier'];
    provider = json['provider'];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = _parseTimestamp(json['subscriptionExpiryDate']);
    try {
      if (json['subscription_plan'] != null) {
        if (json['subscription_plan'] is Map<String, dynamic>) {
          subscriptionPlan = SubscriptionPlanModel.fromJson(json['subscription_plan'] as Map<String, dynamic>);
        } else if (json['subscription_plan'] is Map) {
          subscriptionPlan = SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(json['subscription_plan']));
        } else if (json['subscription_plan'] is String) {
          subscriptionPlan = SubscriptionPlanModel(
            id: json['subscriptionPlanId']?.toString(),
            name: json['subscription_plan'] as String,
            // Add other default properties as needed
          );
        }
      } else {
        subscriptionPlan = null;
      }
    } catch (e) {
      print('Error parsing subscription_plan: $e');
      subscriptionPlan = null;
    }
  }
// Helper method to parse shippingAddress with better error handling
  List<ShippingAddress>? _parseShippingAddress(dynamic shippingAddressData) {
    if (shippingAddressData == null) return null;

    final List<ShippingAddress> addresses = [];

    try {
      if (shippingAddressData is String) {
        // Clean the string - remove any extra quotes or escape characters
        String cleanedString = shippingAddressData;

        // Remove outer quotes if they exist
        if (cleanedString.startsWith('"') && cleanedString.endsWith('"')) {
          cleanedString = cleanedString.substring(1, cleanedString.length - 1);
        }

        // Unescape the string
        cleanedString = cleanedString.replaceAll(r'\"', '"');

        // Try to parse as JSON
        final decoded = jsonDecode(cleanedString);

        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              addresses.add(ShippingAddress.fromJson(item));
            } else if (item is Map) {
              // Try to cast it
              addresses.add(ShippingAddress.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      } else if (shippingAddressData is List) {
        // It's already a list
        for (var item in shippingAddressData) {
          if (item is Map<String, dynamic>) {
            addresses.add(ShippingAddress.fromJson(item));
          } else if (item is Map) {
            addresses.add(ShippingAddress.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    } catch (e) {
      print('Error parsing shippingAddress: $e - Data: $shippingAddressData');
    }

    return addresses.isNotEmpty ? addresses : null;
  }
// Add this helper method to parse Timestamp from various types
  Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value;

    if (value is String) {
      // Handle the case where the string might be wrapped in extra quotes
      String dateString = value.replaceAll('"', '');
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return Timestamp.fromDate(dateTime);
      } catch (e) {
        print('Error parsing date: $value - $e');
        return null;
      }
    }

    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

// Your existing _parseBool method (keep this)
  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['zoneId'] = zoneId;
    data['firstName'] = firstName;
    data['firebase_id'] = firebaseId;
    data['lastName'] = lastName;
    data['profilePictureURL'] = profilePictureURL;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['wallet_amount'] = walletAmount ?? 0;
    data['createdAt'] = createdAt;
    data['active'] = active;
    data['role'] = role;
    data['isDocumentVerify'] = isDocumentVerify;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (userBankDetails != null) {
      data['userBankDetails'] = userBankDetails!.toJson();
    }
    if (shippingAddress != null) {
      data['shippingAddress'] =
          shippingAddress!.map((v) => v.toJson()).toList();
    }
    if (role == Constant.userRoleDriver) {
      data['vendorID'] = vendorID;
      data['isActive'] = isActive;
      data['carName'] = carName;
      data['carNumber'] = carNumber;
      data['carPictureURL'] = carPictureURL;
      data['inProgressOrderID'] = inProgressOrderID;
      data['orderRequestData'] = orderRequestData;
      data['rotation'] = rotation;
    }
    if (role == Constant.userRoleVendor) {
      data['vendorID'] = vendorID;
      data['subscriptionPlanId'] = subscriptionPlanId;
      data['subscriptionExpiryDate'] = subscriptionExpiryDate;
      data['subscription_plan'] = subscriptionPlan?.toJson();
    }
    data['appIdentifier'] = appIdentifier;
    data['provider'] = provider;

    return data;
  }
}

class UserLocation {
  double? latitude;
  double? longitude;

  UserLocation({this.latitude, this.longitude});

  UserLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class ShippingAddress {
  String? id;
  String? address;
  String? addressAs;
  String? landmark;
  String? locality;
  UserLocation? location;
  bool? isDefault;

  ShippingAddress(
      {this.address,
      this.landmark,
      this.locality,
      this.location,
      this.isDefault,
      this.addressAs,
      this.id});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    landmark = json['landmark'];
    locality = json['locality'];
    isDefault = json['isDefault'];
    addressAs = json['addressAs'];
    location = json['location'] == null
        ? null
        : UserLocation.fromJson(json['location']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['landmark'] = landmark;
    data['locality'] = locality;
    data['isDefault'] = isDefault;
    data['addressAs'] = addressAs;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }

  String getFullAddress() {
    return '${address == null || address!.isEmpty ? "" : address} $locality ${landmark == null || landmark!.isEmpty ? "" : landmark.toString()}';
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String holderName;
  String accountNumber;
  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'branchName': branchName,
      'holderName': holderName,
      'accountNumber': accountNumber,
      'otherDetails': otherDetails,
    };
  }
}
