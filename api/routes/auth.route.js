import express from "express";
const router = express.Router();
import { dangnhap, dangxuat } from "../controller/auth.controller.js";

router.post("/dangnhap", dangnhap);
router.post("/dangxuat", dangxuat);
export default router;
