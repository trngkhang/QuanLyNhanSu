import express from "express";
const router = express.Router();
import { dangnhap } from "../controller/auth.controller.js";

router.post("/dangnhap", dangnhap);

export default router;
