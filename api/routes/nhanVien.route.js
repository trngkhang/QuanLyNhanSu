import express from "express";
import { tatcanhanvien } from "../controller/nhanVien.controller.js";
const router = express.Router();

router.get("/tatcanhanvien", tatcanhanvien);

export default router;
