const mongoose = require("mongoose");

exports.mongoDB = async () => {
  await mongoose
    .connect(
      "mongodb+srv://biswajitpanda552:k7cQDuSS8thpWq00@jatpatdekho.b06hwnv.mongodb.net/",
      {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    )
    .then(() => {
      console.log("database connection established");
    })
    .catch((e) => {
      console.log(e);
    });
};

exports.conn = mongoose.connection;
