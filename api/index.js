import express from "express";
import sqlConnection from "./config/database.js";

const app = express();

sqlConnection()
  .then(() => {
    app.listen(3000, () => {
      console.log("Server is running on port 3000");
    });
  })
  .catch((error) => {
    console.error("Error connecting to SQL Server:", error.message);
  });
