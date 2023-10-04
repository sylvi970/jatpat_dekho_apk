const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const saltRounds = 10;

var userSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
    unique: true,
  },
  photo: [
    {
      type: String,
      required: true,
    },
  ],
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  cPassword: {
    type: String,
    required: true,
  },
  rCode: {
    type: String,
  },

  dob: {
    type: Date,
  },
  gender: {
    type: String,
  },
  profession: {
    type: String,
  },
  education: {
    type: String,
  },
  company: {
    type: String,
  },
  products: [
    {
      type: String,
    },
  ],
});

userSchema.pre(`save`, async function (next) {
  if (this.isModified(`password`)) {
    this.password = await bcrypt.hash(this.password, saltRounds);
    this.cPassword = await bcrypt.hash(this.password, saltRounds);
  }
  next();
});

let user = mongoose.model("user", userSchema);

module.exports = user;
