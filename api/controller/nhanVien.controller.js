import { errorHandler } from "../utils/error.js";
import sql from "mssql";

export const tatcanhanvien = async (req, res, next) => {
  try {
    const result = await sql.query`execute SP_SE_NHANVIEN`;
    console.log(result.recordsets[1][0].TruyVan);
    // if (result.recordsets[1][0].TruyVan === "ThanhCong") {
    //   return res.status(200).json(result.recordsets[0]);
    // }
    return res.status(200).json(result.recordsets[0]);
  } catch (error) {
    next(error);
  }
};
