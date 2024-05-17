import sql from "mssql";

const sqlConfig = {
  //yeu cau cau hinh tai khan sa
  user: "QLNS_Login",
  password: "QLNS_Login",
  database: "QLNS",
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
  } catch (err) {
    console.log(err);
  }
};

export default sqlConnection;
