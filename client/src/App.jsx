import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./App.css";
import Header from "./components/Header";
import Home from "./pages/Home";
import Footer from "./components/Footer";
import DangNhap from "./pages/DangNhap";
import Dashboard from "./pages/Dashboard";
import PrivateRoute from "./components/PrivateRoute";
import SuaNhanVien from "./pages/SuaNhanVien";
import ThemNhanVien from "./pages/ThemNhanVien";

function App() {
  return (
    <BrowserRouter>
      <Header />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dangnhap" element={<DangNhap />} />
        <Route element={<PrivateRoute />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/suanhanvien/:nhanvienId" element={<SuaNhanVien />} />
          <Route path="/themnhanvien" element={<ThemNhanVien />} />
        </Route>
      </Routes>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
