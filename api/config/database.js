import sql from "mssql";

const sqlConfig = {
  //yeu cau cau hinh tai khan sa
  user: "sa",
  password: "123456",
  database: "QuanLyNhanVien",
  server: "localhost",
  options: {
    encrypt: true, // for azure
    trustServerCertificate: true, // change to true for local dev / self-signed certs
    trustedConnection: true,
  },
};

const sqlConnection = async () => {
  try {
    await sql.connect(sqlConfig);
    console.log("Ket noi co so du lieu thanh cong!!!");
  } catch (err) {
    console.log(err);
  }
};

export default sqlConnection;
