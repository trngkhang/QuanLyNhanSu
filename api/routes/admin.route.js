import express from "express";
const router = express.Router();
import { test,taotaikhoan } from "../controller/admin.controller.js";

router.get("/test", test);
router.post("/taotaikhoan",taotaikhoan)
export default router;
