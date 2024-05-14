import {
  Alert,
  Button,
  Label,
  Select,
  Spinner,
  TextInput,
} from "flowbite-react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import {
  signInStart,
  signInSuccess,
  signInFailure,
} from "../redux/user/userSlice";

export default function DangNhap() {
  const [formData, setFormData] = useState({});
  const { loading, error: errorMessage } = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.id]: e.target.value.trim() });
  };
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.maNV || !formData.matKhau) {
      return dispatch(signInFailure("Please fill out all fields."));
    }
    try {
      dispatch(signInStart());
      const res = await fetch("/api/auth/dangnhap", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });
      const data = await res.json();
      console.log(data[1][0]);
      if (data[0][0].TruyVan === "ThanhCong") {
        dispatch(signInSuccess(data[1][0]));
        navigate("/");
        return;
      }
      dispatch(signInFailure("Tài khoản không hợp lệ"));
      return;
    } catch (error) {
      dispatch(signInFailure(error.message));
    }
  };

  return (
    <div className="min-h-screen my-20">
      <div className="flex p-3 max-w-3xl mx-auto flex-col md:flex-row md:items-center gap-5">
        {/* left */}
        <div className="flex-1">
          <Link to="/" className="font-bold dark:text-white text-4xl">
            <span className="px-2 py-1 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 rounded-lg text-white">
              Nhóm 6
            </span>
            Quản lý nhân sự
          </Link>
          <p className="text-sm mt-5">Quản lý nhân sự cho doanh nghiệp.</p>
        </div>
        {/* right */}

        <div className="flex-1">
          <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
            <div>
              <Label value="Mã nhân viên" />
              <TextInput
                required
                type="text"
                placeholder="Mã nhân viên của bạn"
                id="maNV"
                onChange={handleChange}
              />
            </div>
            <div>
              <Label value="Mật khẩu" />
              <TextInput
                required
                type="password"
                placeholder="**********"
                id="matKhau"
                onChange={handleChange}
              />
            </div>

            <Button
              gradientDuoTone="purpleToPink"
              type="submit"
              disabled={loading}
            >
              {loading ? (
                <>
                  <Spinner size="sm" />
                  <span className="pl-3">Loading...</span>
                </>
              ) : (
                "Đăng nhập"
              )}
            </Button>
          </form>
          {errorMessage && (
            <Alert className="mt-5" color="failure">
              {errorMessage}
            </Alert>
          )}
        </div>
      </div>
    </div>
  );
}
