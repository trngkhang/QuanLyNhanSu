import { errorHandler } from "../utils/error.js";
import sql from "mssql";

// export const tatcanhanvien = async (req, res, next) => {
//   try {
//     const result2 = await sql.query`select user_name()`;
//     console.log(result2);
//     const result = await sql.query`execute SP_SEL_NHANVIEN_NhanVienRole`;
//     console.log(result);
//     // if (result.recordsets[1][0].TruyVan === "ThanhCong") {
//     //   return res.status(200).json(result.recordsets[0]);
//     // }
//     return res.status(200).json(result.recordsets[0]);
//   } catch (error) {
//     next(error);
//   }
// };
export const tatcanhanvien = async (req, res, next) => {
  try {
    const result0 = await sql.query`select user_name()`;

    console.log(result0);

    const role = req.params.role;
    const queryStr = "execute SP_SEL_NHANVIEN_" + role;

    const result = await sql.query(queryStr);

    // if (result.recordsets[1][0].TruyVan === "ThanhCong") {
    //   return res.status(200).json(result.recordsets[0]);
    // }
    return res.status(200).json(result.recordsets[0]);
  } catch (error) {
    next(error);
  }
};
export const motnhanvien = async (req, res, next) => {
  try {
    const maNV = Number(req.query.nhanvienId);
    console.log("manvvvvvvvv", maNV);
    const result = await sql.query`execute SP_SEL_motNHANVIEN ${maNV}`;
    console.log("motnhanvien", result);
    return res.status(200).json(result.recordsets[0][0]);
  } catch (error) {
    next(error);
  }
};
export const suanhanvien = async (req, res, next) => {};
export const themnhanvien = async (req, res, next) => {
  try {
    const result0 = await sql.query`select user_name()`;
    console.log(result0);
    
    const queryStr = "execute SP_SEL_NHANVIEN_" + role;

    const result = await sql.query(queryStr);

    // if (result.recordsets[1][0].TruyVan === "ThanhCong") {
    //   return res.status(200).json(result.recordsets[0]);
    // }
    return res.status(200).json(result.recordsets[0]);
  } catch (error) {
    next(error);
  }
};