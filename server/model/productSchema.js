const mongoose = require("mongoose");

var productSchema = new mongoose.Schema({
  pId: {
    type: String,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },

  photos: [{ type: String }],
  seller: {
    type: String,
    required: true,
  },
});

let product = mongoose.model("product", productSchema);

module.exports = product;
