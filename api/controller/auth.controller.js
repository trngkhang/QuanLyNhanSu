import { errorHandler } from "../utils/error.js";
import sql from "mssql";
import jwt from "jsonwebtoken";

export const dangnhap = async (req, res, next) => {
  console.log(req.body);
  const { maNV, matKhau, role } = req.body;
  if (
    !maNV ||
    !matKhau ||
    !role ||
    maNV === "" ||
    matKhau === "" ||
    role === ""
  ) {
    return next(errorHandler(400, "All fields are required"));
  }
  try {
    if (role === "QuanTriTaiKhoanRole") {
      const result =
        await sql.query`execute SP_DangNhapTaiKhoanQuanTri ${maNV}, ${matKhau}`;
      if (result.recordset[0].message === "Successful") {
        const token = jwt.sign({ maNV: maNV }, "jwt");
        return res
          .status(200)
          .cookie("access_token", token, {
            httpOnly: true,
          })
          .json(result.recordset[0]);
      }
      return res.json(result.recordset[0]);
    }
  } catch (error) {
    next(error);
  }
};
