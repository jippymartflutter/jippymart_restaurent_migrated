# API Response Spec: Add From Catalog

This document describes the **exact JSON responses** your backend must return for the Flutter "Add from catalog" flow. The app already uses **GET api/restaurant/vendor-categories** for categories; you only need to implement the two endpoints below.

---

## 1. GET Master Products by Category

**Endpoint:** `GET /api/foods/master-products`

**Query parameters:**

| Parameter     | Type   | Required | Description                    |
|--------------|--------|----------|--------------------------------|
| category_id  | string | Yes      | UUID (or id) of vendor category |
| page         | int    | No       | Default 1                      |
| per_page     | int    | No       | Default 10, max 100            |
| search       | string | No       | Filter by product name (LIKE)  |

**Headers (if you use auth):**  
`Authorization: Bearer <token>`  
`Accept: application/json`

---

### Success response (200)

```json
{
  "success": true,
  "products": [
    {
      "id": "prod_uuid_1",
      "name": "Classic Burger",
      "description": "Juicy beef patty with lettuce and sauce",
      "photo": "https://example.com/burger.jpg",
      "suggested_price": 120.00,
      "veg": false,
      "nonveg": true,
      "is_existing": false,
      "options": [
        {
          "id": "opt1",
          "title": "Regular",
          "subtitle": "250g",
          "price": 120
        },
        {
          "id": "opt2",
          "title": "Large",
          "subtitle": "400g",
          "price": 160
        }
      ]
    },
    {
      "id": "prod_uuid_2",
      "name": "Veg Wrap",
      "description": "Fresh wrap",
      "photo": "https://example.com/wrap.jpg",
      "suggested_price": 90.00,
      "veg": true,
      "nonveg": false,
      "is_existing": true,
      "vendor_product_id": "vp_uuid_123",
      "vendor_price": "165.00",
      "vendor_merchantPrice": "120.00",
      "vendor_disPrice": "150.00",
      "vendor_publish": true,
      "vendor_isAvailable": true,
      "vendor_addOnsTitle": ["Extra Cheese", "Bacon"],
      "vendor_addOnsPrice": ["20.00", "35.00"],
      "vendor_available_days": ["Monday", "Tuesday", "Friday"],
      "vendor_available_timings": [
        {
          "day": "Monday",
          "timeslot": [
            { "from": "09:00", "to": "22:00" }
          ]
        }
      ],
      "vendor_options": [
        {
          "id": "opt1",
          "title": "Regular",
          "price": "130",
          "is_available": true
        }
      ],
      "options": [
        { "id": "opt1", "title": "Regular", "subtitle": "250g", "price": 120 },
        { "id": "opt2", "title": "Large", "subtitle": "400g", "price": 160 }
      ]
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total": 47,
    "last_page": 5,
    "from": 1,
    "to": 10
  }
}
```

**Field rules:**

- **products[].id** – Master product ID (required).
- **products[].name, description, photo, suggested_price, veg, nonveg** – From master catalog.
- **products[].is_existing** – `true` if this vendor already has this product in their menu; otherwise `false`.
- **products[].options** – Array of size/variant options from master product. Each has `id`, `title`, `subtitle` (optional), `price` (number).
- When **is_existing** is `true`, include the **vendor_*** fields so the app can pre-fill the form:
  - **vendor_product_id** – Existing vendor product ID (for update).
  - **vendor_price** – Current online (customer) price (string or number).
  - **vendor_merchantPrice** – Merchant’s base price (string or number).
  - **vendor_disPrice** – Discount price (string or number).
  - **vendor_publish**, **vendor_isAvailable** – Booleans.
  - **vendor_addOnsTitle**, **vendor_addOnsPrice** – Arrays of strings (same length).
  - **vendor_available_days** – Array of day names: `"Monday"`, `"Tuesday"`, etc.
  - **vendor_available_timings** – Array of `{ "day": "Monday", "timeslot": [ { "from": "09:00", "to": "22:00" } ] }`.
  - **vendor_options** – Array of `{ "id", "title", "price", "is_available" }` (vendor overrides).
- **pagination** – Required for pagination UI. All fields integers.

---

## 2. POST Bulk Store (Save selected products)

**Endpoint:** `POST /api/foods/store`

**Headers:**  
`Content-Type: application/x-www-form-urlencoded`  
`Accept: application/json`  
`Authorization: Bearer <token>` (if you use auth)

**Body:** Form-encoded (not JSON). The Flutter app sends:

- `selected_products[0][master_product_id]`
- `selected_products[0][vendor_product_id]` (only when updating existing)
- `selected_products[0][merchant_price]`
- `selected_products[0][online_price]`
- `selected_products[0][discount_price]`
- `selected_products[0][publish]` = `0` or `1`
- `selected_products[0][isAvailable]` = `0` or `1`
- `selected_products[0][addons_title][]`, `selected_products[0][addons_price][]` (repeated per add-on)
- `selected_products[0][available_days][]` (repeated: Monday, Tuesday, …)
- `selected_products[0][available_timings][Monday][0][from]`, `[to]`, etc.
- `selected_products[0][options][0]` = JSON string: `{"id":"opt1","title":"Regular","price":"130","original_price":"120","is_available":true}`

---

### Success response (200)

```json
{
  "success": true,
  "message": "Successfully imported 2 product(s).",
  "imported": 2,
  "errors": []
}
```

- **message** – Shown to the user (e.g. success message).
- **imported** – Number of products created/updated.
- **errors** – Empty array on success, or list of error strings if partial failure (app will still treat as success if `success` is true).

---

### Error response (4xx or success: false)

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "selected_products.0.merchant_price": ["The merchant price field is required."],
    "selected_products.1.online_price": ["The online price must be at least 0."]
  }
}
```

- **errors** – Object: key = field path (e.g. `selected_products.0.merchant_price`), value = array of error messages (strings).
- The app shows the first available error message to the user.

---

## Summary

| Endpoint                     | Method | Response shape |
|-----------------------------|--------|----------------|
| `/api/foods/master-products`| GET    | `{ success, products[], pagination{} }` |
| `/api/foods/store`          | POST   | Success: `{ success: true, message, imported, errors: [] }`; Error: `{ success: false, message, errors: {} }` |

Categories continue to use your existing **GET api/restaurant/vendor-categories** (same as the current Add Product screen).

---

## Edit Product – API fields for add-ons and options

The **Edit Product** screen (when you tap a product in the list) loads product data from your **product list** or **get product by id** API. For **add-ons** and **options/variants** to show correctly, each product in the response must include these fields.

**Endpoint that must return this shape:**  
`GET api/restaurant/products?vendorID=...` (list) or `GET api/restaurant/products/{id}` (single product).  
The same structure is used for each product in the list or the single product in `data`.

### Fields to return (per product)

| Field | API key (use either) | Type | Description |
|-------|----------------------|------|--------------|
| Add-on titles | `addOnsTitle` or `add_ons_title` | array of strings | e.g. `["Extra Cheese", "Bacon"]` |
| Add-on prices | `addOnsPrice` or `add_ons_price` | array of strings/numbers | Same length as titles, e.g. `["20.00", "35.00"]` |
| Options / variants | `item_attribute` or `itemAttribute` or `options` | object | See structure below |

### `item_attribute` / options object structure

So that **Options / Variants** show in the edit screen, return an object with `attributes` and `variants`:

```json
"item_attribute": {
  "attributes": [
    {
      "attribute_id": "attr_1",
      "attribute_options": ["Regular", "Large"]
    }
  ],
  "variants": [
    {
      "variant_sku": "Regular",
      "variant_price": "120",
      "variant_id": "v1",
      "variant_quantity": "0",
      "variant_image": ""
    },
    {
      "variant_sku": "Large",
      "variant_price": "160",
      "variant_id": "v2",
      "variant_quantity": "0",
      "variant_image": ""
    }
  ]
}
```

API keys for each variant can be **snake_case** (`variant_sku`, `variant_price`) or **camelCase** (`variantSku`, `variantPrice`).

### Example product object (for list or by-id response)

```json
{
  "id": "prod_123",
  "name": "Classic Burger",
  "description": "Juicy beef patty",
  "photo": "https://...",
  "price": "165.00",
  "merchant_price": "120.00",
  "disPrice": "150.00",
  "categoryID": "cat_uuid",
  "publish": true,
  "isAvailable": true,
  "veg": false,
  "nonveg": true,
  "addOnsTitle": ["Extra Cheese", "Bacon"],
  "addOnsPrice": ["20.00", "35.00"],
  "item_attribute": {
    "attributes": [...],
    "variants": [
      { "variant_sku": "Regular", "variant_price": "120" },
      { "variant_sku": "Large", "variant_price": "160" }
    ]
  }
}
```

If your API uses different keys, the app now accepts:

- Add-ons: `add_ons_title` / `add_ons_price` in addition to `addOnsTitle` / `addOnsPrice`.
- Options: `item_attribute`, `itemAttribute`, or `options` (same object shape).
- Variant fields: `variant_sku` or `variantSku`, `variant_price` or `variantPrice`, etc.
