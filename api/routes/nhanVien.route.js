import express from "express";
import { tatcanhanvien } from "../controller/nhanVien.controller.js";
const router = express.Router();

router.get("/tatcanhanvien", tatcanhanvien);
router.get("/tatcanhanvien/:role", tatcanhanvien);
export default router;
