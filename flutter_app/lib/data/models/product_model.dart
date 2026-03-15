import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product.dart' as domain;

part 'product_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ProductModel {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final String? serverId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? barcode;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  @JsonKey(unknownEnumValue: SyncAction.create)
  final SyncAction syncAction;

  @HiveField(11)
  final DateTime? lastSyncedAt;

  @HiveField(12)
  final bool isDeleted;

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductModel copyWith({
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
    return ProductModel(
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

  // Convert to API format
  Map<String, dynamic> toApiJson() {
    return {
      'clientId': localId,
      'name': name,
      'barcode': barcode,
      'price': price,
      'quantity': quantity,
      'description': description,
    };
  }

  // Mapper: Convert ProductModel to Domain Entity
  domain.Product toEntity() {
    return domain.Product(
      localId: localId,
      serverId: serverId,
      name: name,
      barcode: barcode,
      price: price,
      quantity: quantity,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
      syncAction: _mapSyncActionToEntity(syncAction),
      lastSyncedAt: lastSyncedAt,
      isDeleted: isDeleted,
    );
  }

  // Mapper: Create ProductModel from Domain Entity
  factory ProductModel.fromEntity(domain.Product entity) {
    return ProductModel(
      localId: entity.localId,
      serverId: entity.serverId,
      name: entity.name,
      barcode: entity.barcode,
      price: entity.price,
      quantity: entity.quantity,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
      syncAction: _mapSyncActionFromEntity(entity.syncAction),
      lastSyncedAt: entity.lastSyncedAt,
      isDeleted: entity.isDeleted,
    );
  }

  static domain.SyncAction _mapSyncActionToEntity(SyncAction action) {
    switch (action) {
      case SyncAction.create:
        return domain.SyncAction.create;
      case SyncAction.update:
        return domain.SyncAction.update;
      case SyncAction.delete:
        return domain.SyncAction.delete;
    }
  }

  static SyncAction _mapSyncActionFromEntity(domain.SyncAction action) {
    switch (action) {
      case domain.SyncAction.create:
        return SyncAction.create;
      case domain.SyncAction.update:
        return SyncAction.update;
      case domain.SyncAction.delete:
        return SyncAction.delete;
    }
  }
}

@HiveType(typeId: 1)
enum SyncAction {
  @HiveField(0)
  create,

  @HiveField(1)
  update,

  @HiveField(2)
  delete,
}
