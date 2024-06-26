import { errorHandler } from "../utils/error.js";
import sql from "mssql";
import jwt from "jsonwebtoken";

export const dangnhap = async (req, res, next) => {
  const { maNV, matKhau } = req.body;
  if (!maNV || !matKhau || maNV === "" || matKhau === "") {
    return next(errorHandler(400, "All fields are required"));
  }
  try {
    console.log("req.body", req.body);
    const result = await sql.query`execute SP_SEL_DANGNHAP ${maNV}, ${matKhau}`;
    console.log("result", result);
    if (result.recordsets[0][0].TruyVan === "ThanhCong") {
      const maNVStr = String(maNV);
      const result_login = await sql.query`execute as login = ${maNVStr}`;
      console.log("result_login", result_login);
      const token = jwt.sign({ maNV: maNV }, "jwt");
      return res
        .status(200)
        .cookie("access_token", token, {
          httpOnly: true,
        })
        .json(result.recordsets);
    }
    return res.status(200).json(result.recordsets);
  } catch (error) {
    next(error);
  }
};

export const dangxuat = async (req, res, next) => {
  try {
    const result = await sql.query`revert`;
    return res
      .clearCookie("access_token")
      .status(200)
      .json("Tài khoản đã đăng xuất");
  } catch (error) {
    next(error);
  }
};
