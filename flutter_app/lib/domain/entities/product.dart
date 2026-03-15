enum SyncAction { create, update, delete }

class Product {
  final String localId;
  final String? serverId;
  final String name;
  final String? barcode;
  final double price;
  final int quantity;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final SyncAction syncAction;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  Product({
    required this.localId,
    this.serverId,
    required this.name,
    this.barcode,
    required this.price,
    required this.quantity,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.syncAction = SyncAction.create,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  Product copyWith({
    String? localId,
    String? serverId,
    String? name,
    String? barcode,
    double? price,
    int? quantity,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    SyncAction? syncAction,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Product(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncAction: syncAction ?? this.syncAction,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
