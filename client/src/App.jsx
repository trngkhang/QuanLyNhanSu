import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./App.css";
import Header from "./component/Header";
import Home from "./pages/Home";
import Footer from "./component/Footer";
import DangNhap from "./pages/DangNhap";

function App() {
  return (
    <BrowserRouter>
      <Header />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dangnhap" element={<DangNhap />} />
      </Routes>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
