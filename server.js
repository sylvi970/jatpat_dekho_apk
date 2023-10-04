const express = require("express");
const bodyParser = require("body-parser");
const session = require("express-session");
const crypto = require("crypto");
const dotenv = require("dotenv");
const bcrypt = require("bcrypt");
const morgan = require("morgan");
const mongoose = require("mongoose");
const multer = require("multer");
const path = require("path");
const User = require("./server/model/userSchema");
const Product = require("./server/model/productSchema");
const services = require("./server/services/render");
const connect = require("./server/database/connect");

dotenv.config({ path: "./config.env" });
const port = process.env.PORT || 8080;

const app = express();

//mongodb connection
connect.mongoDB();
// Set the destination directory for uploaded files
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "public/uploads");
  },
  filename: function (req, file, cb) {
    // Generate a unique filename with the original extension
    const uniqueFileName = `${Date.now()}${path.extname(file.originalname)}`;
    cb(null, uniqueFileName);
  },
});

const upload = multer({ storage });

var userId = 1;
var businessId = 1;
var memberId = 1;
var productId = 1;

// Middlewares
//log requests
app.use(morgan("tiny"));
app.use(express.static("./public/uploads"));

//parse requests to body-parser
app.use(bodyParser.json());

//set view engine
app.set("view engine", "ejs");

//set session secret
const sessionSecret = crypto.randomBytes(32).toString("hex");

app.use(
  session({
    secret: sessionSecret,
    resave: false,
    saveUninitialized: true,
  })
);

//Routes
app.post("/api/login", async (req, res) => {
  const { email, password } = req.body;
  // Find the user with the provided username
  const user = await User.findOne({ email: email });

  if (!user) {
    return res
      .status(400)
      .json(
        "This mail id is not with us. Please sign up or use a different mail id to continue."
      );
  }

  // Compare the provided password with the hashed password in the database
  bcrypt.compare(password, user.password, (err, result) => {
    if (err || !result) {
      let message = "Incorrect password";
      return res.status(400).json(message);
    }

    // Store the user ID in the session to maintain the user's login status
    req.session.userId = user.id;
    res.status(200).json(user);
  });
});

//Signup Route
app.post("/api/users", upload.array("photo", 1), async (req, res) => {
  if (!req.body) {
    var message = "All fields are required";
    res.status(400).json(message);
    return;
  }
  const filePaths = req.files?.map((file) => file.path);
  var rCode = req.body.rCode;
  if (!rCode) {
    if (await User.findOne({ email: req.body.semail })) {
      var message = "User Exist Please Login to continue";
      res.status(401).json(message);
      return;
    }
    if (await User.findOne({ phone: req.body.sphone })) {
      let message = "Existing phone number!! Please Login to continue";
      res.status(401).json(message);
      return;
    }
    let uId = "U".concat(userId.toString());
    const newUser = new User({
      id: uId,
      name: req.body.name,
      email: req.body.email,
      phone: req.body.phone,
      password: req.body.password,
      cPassword: req.body.cPassword,
      photo: filePaths,
    });
    await newUser
      .save()
      .then((data) => {
        userId++;
        let message = "User Creation Successful.";
        res.status(200).json(message);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).json({
          message:
            "Something Unexpected happened at our end. Please Try after sometime",
        });
      });
  } else {
    if (await User.findOne({ email: req.body.email })) {
      var message = "User Exist Please Login to continue";
      res.status(401).json(message);
      return;
    }
    if (await User.findOne({ phone: req.body.phone })) {
      let message = "Existing phone number!! Please Login to continue";
      res.status(401).json(message);
      return;
    }
    let bId = "B".concat(businessId.toString());
    const newBusiness = new User({
      id: bId,
      name: req.body.name,
      email: req.body.email,
      phone: req.body.phone,
      password: req.body.password,
      cPassword: req.body.cPassword,
      rCode: req.body.rCode,
      photo: filePaths,
    });
    await newBusiness
      .save()
      .then((data) => {
        businessId++;
        let message = "User Creation Successful.";
        res.status(200).json(message);
      })
      .catch((error) => {
        res.status(500).json({
          message:
            "Something unexpected happened at our end. Please try after sometime.",
        });
      });
  }
});

app.get("/index", async (req, res) => {
  if (!req.session.userId) {
    const user = {
      id: "null",
    };
    const url = null;
    return res.render("index", { user: user, url: url });
  }

  const user = await User.findOne({ id: req.session.userId });
  if (!user) {
    const user = {
      id: "null",
    };
    const url = null;
    return res.render("index", { user: user, url: url });
  }
  const url = user.photo[0].toString().slice(15).replaceAll("\\", "/");
  res.render("index", { user: user, url: url });
});

app.get("/api/products", async (req, res) => {
  try {
    const products = await Product.find();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch products" });
  }
});

//addProduct route
app.post(
  "/api/products",
  upload.array("productPhotos", 6),
  async (req, res) => {
    // Extract the file paths of the uploaded images
    const filePaths = req.files.map((file) => file.path);
    const uId = req.session.userId;
    const pId = "P".concat(productId.toString());
    // Retrieve the user from the database using req.session.userId
    const seller = await User.findOne({ id: uId });

    if (!seller) {
      // Seller not found, handle error
      return res.status(400).json({ error: "Seller not found" });
    }

    const newProduct = new Product({
      pId: pId,
      name: req.body.productName,
      description: req.body.productDesc,
      price: req.body.price,
      photos: filePaths,
      seller: seller.name,
    });

    try {
      await newProduct.save();
      productId++;
      seller.products.push(pId);
      await seller.save();
      let message = "Product added";
      res.status(200).json(message);
    } catch (error) {
      console.log(error.message);
      res.status(500).json(error.message);
    }
  }
);

// Route to search for products by name
app.get("/api/search/products/:name", async (req, res) => {
  try {
    const searchQuery = req.params.name;
    const products = await Product.find({
      name: { $regex: new RegExp(searchQuery, "i") }, // Case-insensitive search
    });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json("Error searching for products");
  }
});

// Route to search for users by name
app.get("/api/search/users/:name", async (req, res) => {
  try {
    const searchQuery = req.params.name;
    const users = await User.find({
      name: { $regex: new RegExp(searchQuery, "i") }, // Case-insensitive search
    });
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json("Error searching for users");
  }
});

// Logout route
app.get("/api/logout", (req, res) => {
  req.logout();
  res.json({ message: "Logged out successfully" });
});

app.get("/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      console.error("Error destroying session:", err);
    }
    res.redirect("/index");
  });
});

app.listen(port, () => {
  console.log("Port connected to ", port);
});
