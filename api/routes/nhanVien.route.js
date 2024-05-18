import express from "express";
import {
  motnhanvien,
  suanhanvien,
  tatcanhanvien,
  themnhanvien,
} from "../controller/nhanVien.controller.js";
const router = express.Router();

router.get("/tatcanhanvien/:role", tatcanhanvien);
router.get("/motnhanvien", motnhanvien);
router.put("/suanhanvien/:maNV", suanhanvien);
router.post("/themnhanvien", themnhanvien);
export default router;
