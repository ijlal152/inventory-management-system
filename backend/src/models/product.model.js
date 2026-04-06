const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/database");

const Product = sequelize.define(
  "Product",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: {
          msg: "Product name is required",
        },
        len: {
          args: [3, 255],
          msg: "Name must be between 3 and 255 characters",
        },
      },
    },
    barcode: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: {
          args: [0],
          msg: "Price must be positive",
        },
      },
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: {
          args: [0],
          msg: "Quantity must be non-negative",
        },
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    isDeleted: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    clientId: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: {
          msg: "Client ID is required",
        },
      },
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "users",
        key: "id",
      },
      onDelete: "CASCADE",
      onUpdate: "CASCADE",
    },
  },
  {
    tableName: "products",
    timestamps: true,
    indexes: [
      {
        fields: ["isDeleted"],
      },
      {
        fields: ["clientId"],
      },
      {
        fields: ["barcode"],
      },
      {
        fields: ["userId"],
      },
    ],
  },
);

// Define associations
Product.associate = (models) => {
  Product.belongsTo(models.User, {
    foreignKey: "userId",
    as: "user",
  });
};

module.exports = Product;
