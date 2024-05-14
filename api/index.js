import express from "express";
import sqlConnection from "./config/database.js";
import authRoutes from "./routes/auth.route.js";
import adminRoutes from "./routes/admin.route.js";
import nhanVienRoutes from "./routes/nhanvien.route.js";
const app = express();

app.use(express.json());

sqlConnection()
  .then(() => {
    console.log("SQL server is connected");
  })
  .catch((error) => {
    console.error("Error connecting to SQL Server:", error.message);
  });

app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/nhanvien", nhanVienRoutes);

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";
  res.status(statusCode).json({
    success: false,
    statusCode,
    message,
  });
});
