import { errorHandler } from "../utils/error.js";
import sql from "mssql";
import jwt from "jsonwebtoken";

export const dangnhap = async (req, res, next) => {
  const { maNV, matKhau, chucVu } = req.body;
  if (
    !maNV ||
    !matKhau ||
    !chucVu ||
    maNV === "" ||
    matKhau === "" ||
    chucVu === ""
  ) {
    return next(errorHandler(400, "All fields are required"));
  }
  try {
    const result =
      await sql.query`execute SP_SE_NHANVIENDANGNHAP ${maNV}, ${matKhau}, ${chucVu}`;

    if (result.recordsets[0][0].DangNhap === "ThanhCong") {
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
