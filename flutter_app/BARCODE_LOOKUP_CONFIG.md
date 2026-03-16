# Barcode Lookup Configuration

This app supports multiple barcode lookup services to automatically fetch product information when scanning barcodes.

## Available Services

### 1. **Open Food Facts** (Currently Active - FREE)

- **Best for**: Food and beverage products
- **Coverage**: Global product database
- **Pricing**: Free, no API key required
- **Limitations**: Mainly food items, may not have pricing data
- **Documentation**: https://world.openfoodfacts.org/data

### 2. **UPCitemdb.com**

- **Best for**: General products (electronics, household items, etc.)
- **Coverage**: Wide range of products
- **Pricing**: Free tier available with API key
- **Get API Key**: https://www.upcitemdb.com/
- **Limitations**: Rate limits on free tier

### 3. **Custom Backend**

- **Best for**: Your own product database
- **Requires**: Your own API endpoint that returns product details by barcode

## How to Switch Services

Open `/lib/main.dart` and edit the `setupDependencies` function:

### Option 1: Open Food Facts (Default - No API Key)

```dart
final barcodeLookupDataSource = OpenFoodFactsDataSourceImpl(
  client: http.Client(),
);
```

### Option 2: UPCitemdb.com (Requires API Key)

```dart
final barcodeLookupDataSource = UPCItemDBDataSourceImpl(
  client: http.Client(),
  apiKey: 'YOUR_API_KEY_HERE', // Get from https://www.upcitemdb.com/
);
```

### Option 3: Your Custom Backend

```dart
final barcodeLookupDataSource = CustomBackendDataSourceImpl(
  client: http.Client(),
  baseUrl: 'http://your-api.com/api', // Your API base URL
);
```

## How It Works

1. **Scan Barcode**: User scans product barcode
2. **External Lookup**: App queries the configured barcode API
3. **Auto-Fill**: If found, product name, price, description are auto-filled
4. **Fallback**: If not found externally, checks local database
5. **Manual Entry**: If not found anywhere, user enters details manually

## Custom API Format

If you're using a custom backend, your API endpoint should:

**Endpoint**: `GET /products/lookup/{barcode}`

**Response Format**:

```json
{
  "data": {
    "name": "Product Name",
    "price": 12.99,
    "description": "Product description",
    "brand": "Brand Name",
    "category": "Category",
    "image_url": "https://..."
  }
}
```

**On Not Found**: Return 404 status code

## Adding New Services

To add a new barcode lookup service:

1. Create a new class implementing `BarcodeLookupDataSource` in:
   `/lib/data/datasources/remote/barcode_lookup_datasource.dart`

2. Implement the `lookupBarcode` method to call your API

3. Update dependency injection in `/lib/main.dart`
