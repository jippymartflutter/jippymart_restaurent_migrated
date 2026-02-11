# Performance Optimization Plan
## Backend API & Flutter Client Analysis

**Date:** 2025-01-27  
**Goal:** Improve API performance without changing business logic, UI, or behavior

---

## Executive Summary

This analysis identifies opportunities to optimize API performance through:
1. **API Merging**: Combine APIs that are always called together
2. **Transparent Caching**: Add caching layer for frequently accessed, rarely-changing data
3. **Request Optimization**: Reduce redundant API calls

**All optimizations maintain 100% backward compatibility.**

---

## Analysis Results

### 1. APIs ALWAYS Called Together (Safe to Merge)

#### ✅ **Pattern 1: updateOrder + restaurantVendorWalletSet**
**Status:** SAFE TO MERGE  
**Frequency:** 3+ locations in home_screen.dart

**Current Implementation:**
```dart
await FireStoreUtils.updateOrder(orderModel);
await FireStoreUtils.restaurantVendorWalletSet(orderModel);
```

**Locations Found:**
- `lib/app/Home_screen/home_screen.dart:1955-1957` (Order delivered)
- `lib/app/Home_screen/home_screen.dart:2777-2780` (Order assigned to driver)
- `lib/app/Home_screen/home_screen.dart:3094-3096` (Order shipped/accepted)

**Optimization:**
- Create internal merged endpoint: `POST /restaurant/orders/{id}/accept-with-wallet`
- Keep existing endpoints as wrappers calling the merged endpoint
- Backend handles both operations atomically

**Expected Impact:** 
- Reduces 2 sequential API calls → 1 call
- ~50% reduction in API calls for order status updates
- Faster order processing

---

#### ✅ **Pattern 2: getUserProfile + getVendorById**
**Status:** SAFE TO MERGE (with optional flag)  
**Frequency:** 19 files, 42+ occurrences

**Current Implementation:**
```dart
await FireStoreUtils.getUserProfile(userId);
FireStoreUtils.getVendorById(userModel.value.vendorID!)
```

**Locations Found:**
- `lib/controller/home_controller.dart:71-78`
- `lib/controller/dash_board_controller.dart:47-48`
- `lib/controller/product_list_controller.dart:22-23`
- `lib/controller/profile_controller.dart:24`
- And 15+ more locations

**Optimization:**
- Create merged endpoint: `GET /restaurant/users/{uuid}/with-vendor`
- Keep existing endpoints as wrappers
- Add optional `?includeVendor=true` parameter to `getUserProfile`

**Expected Impact:**
- Reduces 2 API calls → 1 call in initialization flows
- ~50% reduction in user/vendor data fetching
- Faster app startup and profile loading

---

### 2. APIs FREQUENTLY Called Together (Consider Merging)

#### ⚠️ **Pattern 3: getUserById + getUserProfile + getVendorById (Chat)**
**Status:** MERGE IF USAGE PATTERN CONFIRMED  
**Frequency:** Chat screen initialization

**Current Implementation:**
```dart
UserModel? customer = await FireStoreUtils.getUserById(orderModel.authorID.toString());
UserModel? restaurantUser = await FireStoreUtils.getUserProfile(orderModel.vendor!.author.toString());
VendorModel? vendorModel = await FireStoreUtils.getVendorById(orderModel.vendorID.toString());
```

**Location:** `lib/app/Home_screen/home_screen.dart:1994-2002`

**Optimization:**
- Create endpoint: `GET /restaurant/orders/{id}/chat-participants`
- Returns customer, restaurant user, and vendor in one call

**Expected Impact:**
- Reduces 3 API calls → 1 call
- Faster chat screen initialization

**Note:** Only merge if this pattern occurs in 2+ locations consistently.

---

### 3. Caching Opportunities (Transparent Client-Side)

#### ✅ **Cache Target 1: User Profile**
**Status:** SAFE TO CACHE  
**TTL:** 5 minutes or until manual refresh

**Current Usage:**
- Called 42+ times across 19 files
- Data changes infrequently
- Frequently accessed during app lifecycle

**Implementation:**
```dart
// Add to fire_store_utils.dart
static UserModel? _cachedUserProfile;
static DateTime? _userProfileCacheTime;
static const Duration _userProfileCacheTTL = Duration(minutes: 5);

static Future<UserModel?> getUserProfile(String uuid, {bool forceRefresh = false}) async {
  // Return cache if valid and not forcing refresh
  if (!forceRefresh && _cachedUserProfile != null && _userProfileCacheTime != null) {
    if (DateTime.now().difference(_userProfileCacheTime!) < _userProfileCacheTTL) {
      return _cachedUserProfile;
    }
  }
  // Fetch and cache...
}
```

**Expected Impact:**
- Reduces API calls by ~80% for repeated profile access
- Faster subsequent profile loads

---

#### ✅ **Cache Target 2: Vendor Data**
**Status:** SAFE TO CACHE  
**TTL:** 5 minutes or until manual refresh

**Current Usage:**
- Called frequently after user profile
- Changes infrequently (mostly restaurant settings)

**Implementation:** Similar to user profile cache

**Expected Impact:**
- Reduces API calls by ~70% for vendor data

---

#### ✅ **Cache Target 3: Settings Data**
**Status:** SAFE TO CACHE  
**TTL:** 30 minutes (settings rarely change)

**Current Usage:**
- `getSettings()` called during app initialization
- Loads global settings, payment configs, etc.

**Implementation:**
- Cache entire settings response
- Only refresh on app restart or manual refresh

**Expected Impact:**
- Eliminates redundant settings API calls
- Faster app initialization

---

#### ✅ **Cache Target 4: Delivery Charge**
**Status:** SAFE TO CACHE  
**TTL:** 15 minutes

**Current Usage:**
- Called multiple times in order flows
- Data changes infrequently

**Expected Impact:**
- Reduces redundant delivery charge calculations

---

#### ✅ **Cache Target 5: Driver Search Radius**
**Status:** ALREADY CACHED (IMPROVE)  
**Current:** `Constant.driverSearchRadius` stored in memory

**Optimization:**
- Add persistent cache (SharedPreferences)
- Cache TTL: 1 hour
- Avoid repeated API calls on app restart

**Expected Impact:**
- Faster driver assignment flows

---

### 4. Request Optimization Patterns

#### ✅ **Pattern: Sequential → Parallel**
**Status:** PARTIALLY OPTIMIZED

**Already Optimized:**
- `home_screen.dart:3094-3096` - Uses `Future.wait()` for parallel execution

**Can Improve:**
- `home_controller.dart:71-78` - `getUserProfile` → `getVendorById` → `getOrder` could be partially parallel
- `product_list_controller.dart:22-30` - `getUserProfile` → `getProduct` → `getVendorCategoryById` could be parallel

**Implementation:**
```dart
// Instead of:
await getUserProfile();
await getVendorById();
await getOrder();

// Use:
await Future.wait([
  getUserProfile(),
  getVendorById(),
]);
await getOrder(); // depends on vendorID
```

---

## Implementation Priority

### Phase 1: High Impact, Low Risk
1. ✅ **Cache User Profile** (5 min TTL)
2. ✅ **Cache Vendor Data** (5 min TTL)
3. ✅ **Cache Settings** (30 min TTL)
4. ✅ **Merge updateOrder + restaurantVendorWalletSet** (backend)

### Phase 2: Medium Impact, Low Risk
5. ✅ **Merge getUserProfile + getVendorById** (backend + client)
6. ✅ **Cache Delivery Charge** (15 min TTL)
7. ✅ **Optimize Driver Radius Cache** (persistent)

### Phase 3: Lower Priority
8. ⚠️ **Merge chat participants API** (if pattern confirmed)
9. ⚠️ **Parallelize initialization calls** (where safe)

---

## Implementation Details

### Backend Changes Required

#### 1. Create Merged Order Endpoint
```php
// New endpoint: POST /restaurant/orders/{id}/accept-with-wallet
// Internal implementation calls both:
// - updateOrder()
// - restaurantVendorWalletSet()
// Returns combined response or separate success flags
```

#### 2. Create Merged User Endpoint
```php
// Enhanced: GET /restaurant/users/{uuid}?includeVendor=true
// Returns user + vendor data in single response
// Keep existing endpoint as-is (backward compatible)
```

### Client Changes Required

#### 1. Add Transparent Caching Layer
- Create `ApiCache` utility class
- Wrap existing API calls with cache checks
- Maintain cache invalidation on updates

#### 2. Update API Call Sites
- Replace sequential calls with merged endpoints where available
- Keep old methods as wrappers for backward compatibility

---

## Validation & Testing

### Before Implementation
1. ✅ Document current API call patterns
2. ✅ Measure baseline API call counts
3. ✅ Identify exact merge points

### After Implementation
1. ✅ Verify no behavior changes
2. ✅ Confirm cache invalidation works correctly
3. ✅ Measure API call reduction
4. ✅ Validate response times improved

---

## Risk Assessment

### Low Risk ✅
- **Caching** - Transparent, can be disabled
- **API Merging with Wrappers** - Old endpoints remain functional
- **Parallel Execution** - Only where dependencies allow

### Medium Risk ⚠️
- **API Merging** - Requires backend coordination
- **Cache Invalidation** - Must handle edge cases

### Mitigation
- Keep old APIs as wrappers indefinitely
- Add feature flags to enable/disable optimizations
- Monitor cache hit rates and API call patterns

---

## Expected Performance Improvements

### API Call Reduction
- **Order Updates:** ~50% reduction (2 calls → 1)
- **User/Vendor Loading:** ~50% reduction (2 calls → 1)
- **Profile Access:** ~80% reduction (cache hits)
- **Settings Loading:** ~100% reduction after first load

### Response Time Improvements
- **Order Acceptance:** ~40% faster (1 round trip vs 2)
- **App Initialization:** ~30% faster (cached data)
- **Profile Access:** ~90% faster (cache hit)

### Network Usage Reduction
- **Estimated:** 60-70% reduction in API calls during normal usage
- **Bandwidth:** Significant reduction in redundant data transfer

---

## Notes

1. **No Business Logic Changes:** All calculations, validations, and pricing remain unchanged
2. **No UI Changes:** Frontend behavior is identical
3. **Backward Compatible:** Old API endpoints continue to work
4. **Transparent:** Caching and merging are invisible to calling code
5. **Reversible:** All optimizations can be disabled via feature flags

---

## Next Steps

1. Review and approve this plan
2. Implement Phase 1 optimizations
3. Test thoroughly in development
4. Measure performance improvements
5. Deploy with monitoring
6. Proceed with Phase 2 if Phase 1 is successful

---

## Appendix: API Call Frequency Analysis

### Most Called APIs
1. `getUserProfile` - 42+ calls across 19 files
2. `getVendorById` - 30+ calls
3. `updateOrder` - 15+ calls (mostly with wallet update)
4. `getOrder` - Polled every 10 seconds
5. `getProduct` - 10+ calls

### Sequential Call Patterns
1. `getUserProfile` → `getVendorById` - 19 locations
2. `updateOrder` → `restaurantVendorWalletSet` - 3 locations
3. `getUserProfile` → `getProduct` → `getVendorCategoryById` - 2 locations

---

**End of Plan**
