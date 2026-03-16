import '../../data/datasources/remote/barcode_lookup_datasource.dart';

class LookupBarcodeUseCase {
  final BarcodeLookupDataSource barcodeLookupDataSource;

  LookupBarcodeUseCase(this.barcodeLookupDataSource);

  Future<BarcodeLookupResult?> execute(String barcode) async {
    if (barcode.trim().isEmpty) {
      return null;
    }
    return await barcodeLookupDataSource.lookupBarcode(barcode.trim());
  }
}
