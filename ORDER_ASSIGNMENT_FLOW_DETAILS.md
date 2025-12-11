# Order Assignment Flow - Complete Details

## Overview
This document explains the complete flow of order assignment in the restaurant app, including when the driver selection dialog appears, what data is fetched, and how notifications are sent.

---

## 📋 Table of Contents
1. [Order Acceptance Flow](#order-acceptance-flow)
2. [Driver Selection Dialog Flow](#driver-selection-dialog-flow)
3. [Data Fetching Details](#data-fetching-details)
4. [Notification Details](#notification-details)
5. [Code Flow Diagram](#code-flow-diagram)

---

## 1. Order Acceptance Flow

### Step 1: Restaurant Clicks "Accept" Button
**Location:** `home_screen.dart` - Line 1264-1329

When a restaurant clicks the "Accept" button on a new order:
- The `estimatedTimeDialog` is shown first (Line 1320-1326)
- This dialog requires the restaurant to set an estimated preparation time

### Step 2: Estimated Time Dialog
**Location:** `home_screen.dart` - Line 2879-3157

**What happens:**
1. User selects estimated time using duration picker (5-40 minutes)
2. User clicks "Shipped order" button (Line 3024)
3. **Critical Check:** The system checks if self-delivery is enabled:
   ```dart
   if (Constant.isSelfDeliveryFeature == true &&
       controller.vendermodel.value.isSelfDelivery == true &&
       orderModel.takeAway == false)
   ```

### Step 3: Two Different Paths

#### **Path A: Self-Delivery Enabled (Manual Driver Selection)**
**Location:** `home_screen.dart` - Line 3040-3053

**When this path is taken:**
- `Constant.isSelfDeliveryFeature == true`
- `controller.vendermodel.value.isSelfDelivery == true`
- `orderModel.takeAway == false` (Order is NOT takeaway)

**What happens:**
1. Shows loader: `ShowToastDialog.showLoader('Please wait...')`
2. **Fetches driver list:** `await controller.getAllDriverList()` (Line 3044)
3. Closes loader
4. Sets estimated time: `orderModel.estimatedTimeToPrepare = controller.estimatedTimeController.value.text`
5. Closes estimated time dialog: `Get.back()`
6. **Shows driver selection dialog:** `showListOfDeliverymenDialog()` (Line 3048-3052)

#### **Path B: Automatic Driver Assignment**
**Location:** `home_screen.dart` - Line 3054-3138

**When this path is taken:**
- Self-delivery is disabled OR
- Order is takeaway OR
- Restaurant doesn't have self-delivery enabled

**What happens:**
1. Shows loader
2. Sets estimated time
3. Sets order status to `Constant.orderAccepted`
4. Plays sound notification
5. Fetches driver search radius (if not cached)
6. Updates order in database
7. Updates vendor wallet
8. **Automatically finds nearby drivers** within radius
9. **Automatically assigns order to eligible drivers** (adds order ID to their `orderRequestData`)
10. Sends notification to customer
11. Closes dialog

---

## 2. Driver Selection Dialog Flow

### When Dialog Appears
**Location:** `home_screen.dart` - Line 2564-2840

The `showListOfDeliverymenDialog` is called **ONLY** when:
- Self-delivery feature is enabled
- Restaurant has self-delivery enabled
- Order is NOT takeaway
- User has already set estimated time and clicked "Shipped order"

### Dialog Structure

#### **Header Section** (Line 2579-2622)
- Title: "Select the delivery man"
- "Add Delivery Man" button (currently disabled/commented)

#### **Driver Dropdown** (Line 2624-2725)
- Uses `DropdownSearch<UserModel>` widget
- **Data Source:** `controller.driverUserList` (Line 2689)
- **Selected Driver:** `controller.selectDriverUser.value` (Line 2723)
- **Search Functionality:** Enabled with search box
- **Driver Status Display:**
  - Shows "Assign" if driver has no orders in progress (`inProgressOrderID?.isEmpty == true`)
  - Shows "Occupied" if driver already has orders

#### **Driver Selection Logic** (Line 2709-2722)
```dart
onChanged: (value) {
  if (Constant.singleOrderReceive == true) {
    // Only allow assignment if driver has no orders in progress
    if (value?.inProgressOrderID?.isEmpty == true) {
      controller.selectDriverUser.value = value!;
    } else {
      ShowToastDialog.showToast("This delivery man is already assigned...");
      controller.selectDriverUser.value = UserModel();
    }
  } else {
    // Allow multiple orders per driver
    controller.selectDriverUser.value = value!;
  }
}
```

#### **Order Assign Button** (Line 2760-2827)
When clicked:
1. Validates driver is selected
2. Closes dialog
3. Shows loader
4. Plays sound notification
5. Updates subscription order count (if applicable)
6. **Assigns driver to order:**
   - Sets `orderModel.driverID = controller.selectDriverUser.value.id`
   - Sets `orderModel.driver = controller.selectDriverUser.value`
   - Sets `orderModel.status = Constant.orderInTransit`
   - Adds order ID to driver's `inProgressOrderID` list
7. Updates order in database
8. Updates driver user data
9. Updates vendor wallet
10. **Sends notifications** (see Notification Details section)

---

## 3. Data Fetching Details

### Driver List Fetching

#### **Method:** `getAllDriverList()`
**Location:** `lib/controller/home_controller.dart` - Line 133-142

```dart
getAllDriverList() async {
  await FireStoreUtils.getAvalibleDrivers().then(
    (value) {
      if (value.isNotEmpty == true) {
        driverUserList.value = value;
      }
    },
  );
  isLoading.value = false;
}
```

#### **API Call:** `FireStoreUtils.getAvalibleDrivers()`
**Location:** `lib/utils/fire_store_utils.dart` - Line 3067-3106

**Endpoint:** `GET ${Constant.baseUrl}drivers/available`

**What it fetches:**
- List of all available drivers from the API
- Returns `List<UserModel>`
- Drivers are sorted by `createdAt` descending

**When it's called:**
- **BEFORE** showing the driver selection dialog (Line 3044)
- Only in Path A (Self-Delivery Enabled)

### Automatic Driver Assignment Data

#### **Driver Search Radius**
**Location:** `home_screen.dart` - Line 3061-3087

**Endpoint:** `GET ${Constant.baseUrl}restaurant/GetDriverNearBy`

**What it fetches:**
- Driver search radius in kilometers
- Cached in `Constant.driverSearchRadius`
- Default: 5.0 km if not available

#### **Available Drivers**
**Location:** `home_screen.dart` - Line 3094

**Method:** `FireStoreUtils.getAvalibleDrivers()`

**Filtering Logic** (Line 3095-3112):
```dart
List<UserModel> eligibleDrivers = allDrivers.where((driver) {
  // Check if driver has location data
  if (driver.location == null ||
      driver.location!.latitude == null ||
      driver.location!.longitude == null) {
    return false;
  }
  
  // Calculate distance from restaurant
  double distance = Geolocator.distanceBetween(
    restaurantLat, restaurantLng, 
    driverLat, driverLng
  ) / 1000; // Convert to km
  
  // Only include drivers within radius
  return distance <= radius;
}).toList();
```

**What happens:**
1. Gets all available drivers
2. Filters by distance from restaurant
3. Only includes drivers within search radius
4. Updates each driver's `orderRequestData` with order ID
5. Updates driver records sequentially (with 100ms delay to avoid rate limiting)

---

## 4. Notification Details

### Notification Constants
**Location:** `lib/constant/constant.dart` - Line 72-78

```dart
static String restaurantRejected = "restaurant_rejected";
static String restaurantCancelled = "restaurant_cancelled";
static String restaurantAccepted = "restaurant_accepted";
static String newDeliveryOrder = "new_delivery_order";
```

### Notification Flow

#### **1. Order Accepted (Automatic Assignment)**
**Location:** `home_screen.dart` - Line 3128-3135

**When:** Order is accepted and automatically assigned to nearby drivers

**Sent to:** Customer
```dart
if (orderModel.author?.fcmToken != null &&
    orderModel.author!.fcmToken!.isNotEmpty) {
  SendNotification.sendFcmMessage(
    Constant.restaurantAccepted,  // "restaurant_accepted"
    orderModel.author!.fcmToken.toString(),
    {},
  );
}
```

**Notification Type:** `restaurant_accepted`
**Recipient:** Customer (order author)
**Payload:** Empty object `{}`

#### **2. Driver Assigned (Manual Selection)**
**Location:** `home_screen.dart` - Line 2808-2819

**When:** Restaurant manually selects a driver from dialog

**Sent to:** Customer
```dart
if (orderModel.author?.fcmToken != null &&
    orderModel.author!.fcmToken!.isNotEmpty) {
  SendNotification.sendFcmMessage(
    Constant.restaurantAccepted,  // "restaurant_accepted"
    orderModel.author!.fcmToken.toString(),
    {},
  );
}
```

**Sent to:** Driver
```dart
if (orderModel.driver?.fcmToken != null &&
    orderModel.driver!.fcmToken!.isNotEmpty) {
  SendNotification.sendFcmMessage(
    Constant.newDeliveryOrder,  // "new_delivery_order"
    orderModel.driver!.fcmToken.toString(),
    {},
  );
}
```

**Notification Types:**
- `restaurant_accepted` → Customer
- `new_delivery_order` → Driver
**Payload:** Empty object `{}`

#### **3. Order Rejected**
**Location:** `home_screen.dart` - Line 1142-1152

**When:** Restaurant rejects an order

**Sent to:** Customer
```dart
if (orderModel.author?.fcmToken != null &&
    orderModel.author!.fcmToken!.isNotEmpty) {
  SendNotification.sendFcmMessage(
    Constant.restaurantRejected,  // "restaurant_rejected"
    orderModel.author!.fcmToken.toString(),
    {
      'orderId': orderModel.id ?? '',
      'status': Constant.orderRejected,
    },
  );
}
```

**Notification Type:** `restaurant_rejected`
**Recipient:** Customer
**Payload:** `{'orderId': orderId, 'status': 'rejected'}`

#### **4. Order Cancelled**
**Location:** `home_screen.dart` - Line 1859-1869

**When:** Restaurant cancels an accepted order

**Sent to:** Customer
```dart
if (orderModel.author?.fcmToken != null &&
    orderModel.author!.fcmToken!.isNotEmpty) {
  SendNotification.sendFcmMessage(
    Constant.restaurantCancelled,  // "restaurant_cancelled"
    orderModel.author!.fcmToken.toString(),
    {
      'orderId': orderModel.id ?? '',
      'status': Constant.orderCancelled,
    },
  );
}
```

**Notification Type:** `restaurant_cancelled`
**Recipient:** Customer
**Payload:** `{'orderId': orderId, 'status': 'cancelled'}`

---

## 5. Code Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Restaurant Clicks "Accept" Button on New Order            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  estimatedTimeDialog() Shows                                │
│  - User selects duration (5-40 minutes)                     │
│  - User clicks "Shipped order" button                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌──────────────────┐        ┌──────────────────────┐
│ PATH A:          │        │ PATH B:              │
│ Self-Delivery     │        │ Automatic            │
│ Enabled           │        │ Assignment           │
└────────┬─────────┘        └──────────┬──────────┘
         │                              │
         ▼                              ▼
┌──────────────────┐        ┌──────────────────────┐
│ 1. Show Loader   │        │ 1. Show Loader        │
│ 2. getAllDriver  │        │ 2. Set estimated time │
│    List()         │        │ 3. Set status=Accepted│
│ 3. Close Loader  │        │ 4. Play sound         │
│ 4. Set estimated │        │ 5. Get driver radius  │
│    time           │        │ 6. Update order       │
│ 5. Close dialog  │        │ 7. Update wallet      │
│ 6. Show driver    │        │ 8. Find nearby drivers│
│    selection      │        │ 9. Auto-assign orders │
│    dialog         │        │ 10. Send notification │
└────────┬─────────┘        │    to customer        │
         │                  │ 11. Close dialog       │
         ▼                  └──────────┬─────────────┘
┌──────────────────┐                  │
│ showListOf       │                  │
│ DeliverymenDialog│                  │
│                  │                  │
│ - Shows dropdown │                  │
│ - Driver list    │                  │
│   populated      │                  │
│ - Search enabled │                  │
│ - Shows status   │                  │
│   (Assign/       │                  │
│   Occupied)      │                  │
└────────┬─────────┘                  │
         │                             │
         ▼                             │
┌──────────────────┐                  │
│ User selects     │                  │
│ driver and clicks│                  │
│ "Order Assign"    │                  │
└────────┬─────────┘                  │
         │                             │
         ▼                             │
┌──────────────────┐                  │
│ 1. Validate      │                  │
│    driver        │                  │
│ 2. Close dialog  │                  │
│ 3. Show loader   │                  │
│ 4. Play sound    │                  │
│ 5. Update        │                  │
│    subscription  │                  │
│ 6. Assign driver │                  │
│    to order      │                  │
│ 7. Update order  │                  │
│ 8. Update driver │                  │
│ 9. Update wallet│                  │
│ 10. Send         │                  │
│     notifications│                  │
│     - Customer   │                  │
│     - Driver     │                  │
│ 11. Close loader │                  │
└──────────────────┘                  │
         │                             │
         └─────────────┬───────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Order Status Updated  │
            │ - In Transit (Path A) │
            │ - Accepted (Path B)   │
            └──────────────────────┘
```

---

## Summary

### Key Points:

1. **Driver Selection Dialog appears ONLY when:**
   - Self-delivery feature is enabled (`Constant.isSelfDeliveryFeature == true`)
   - Restaurant has self-delivery enabled (`vendermodel.isSelfDelivery == true`)
   - Order is NOT takeaway (`orderModel.takeAway == false`)

2. **Data is fetched:**
   - **Before showing dialog:** `getAllDriverList()` calls API endpoint `drivers/available`
   - **For automatic assignment:** Fetches driver radius and filters drivers by distance

3. **Notifications are sent:**
   - **Customer:** Always notified when order is accepted (`restaurant_accepted`)
   - **Driver:** Only notified when manually assigned (`new_delivery_order`)
   - **Customer:** Notified when order is rejected/cancelled

4. **Two assignment methods:**
   - **Manual (Self-Delivery):** Restaurant selects specific driver
   - **Automatic:** System finds nearby drivers and assigns order to all eligible drivers


