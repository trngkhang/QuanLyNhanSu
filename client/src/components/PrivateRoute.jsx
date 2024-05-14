import { useSelector } from "react-redux";
import { Outlet, Navigate } from "react-router-dom";

export default function PrivateRoute() {
  const { nhanVien } = useSelector((state) => state.user);

  return nhanVien ? <Outlet /> : <Navigate to="/dangnhap" />;
}
