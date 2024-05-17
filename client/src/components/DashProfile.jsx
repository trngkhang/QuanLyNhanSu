import { Label, TextInput } from "flowbite-react";
import { useDispatch, useSelector } from "react-redux";

export default function DashProfile() {
  const dispatch = useDispatch();
  const { nhanVien } = useSelector((state) => state.user);
  return (
    <div className="min-h-screen max-w-3xl mx-auto p-3">
      <h1 className=" text-3xl font-semibold text-center py-7">
        Thông tin nhân viên
      </h1>

      <form className="flex max-w-md flex-col gap-4">
        <div>
          <div className="mb-2 block">
            <Label htmlFor="MaNV" value="Mã nhân viên" />
          </div>
          <TextInput
            id="MaNV"
            type="number"
            required
            value={nhanVien.MaNhanVien}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="HoTen" value="Họ tên" />
          </div>
          <TextInput
            id="HoTen"
            type="text"
            required
            placeholder="Họ tên"
            value={nhanVien.HoTen}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="GioiTinh" value="Giới tính" />
          </div>
          <TextInput
            id="GioiTinh"
            type="text"
            placeholder="Giới tính"
            value={nhanVien.GioiTinh}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="NgaySinh" value="Ngày sinh" />
          </div>
          <TextInput
            id="NgaySinh"
            type="text"
            required
            placeholder="Ngày sinh"
            value={new Date(nhanVien.NgaySinh).toLocaleDateString()}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="SoDienThoai" value="Số điện thoại" />
          </div>
          <TextInput
            id="SoDienThoai"
            type="int"
            maxLength={15}
            required
            placeholder="SĐT"
            value={nhanVien.SoDienThoai}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="Luong" value="Lương" />
          </div>
          <TextInput
            id="Luong"
            type="int"
            required
            placeholder="Lương"
            value={nhanVien.Luong}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="PhuCap" value="Phụ cấp" />
          </div>
          <TextInput
            id="PhuCap"
            type="int"
            required
            placeholder="Phụ cấp"
            value={nhanVien.PhuCap}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="MaSoThue" value="Mã số thuế" />
          </div>
          <TextInput id="MaSoThue" type="text" value={nhanVien.MaSoThue} />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="TenChucVu" value="Tên chức vụ" />
          </div>
          <TextInput id="TenChucVu" type="text" value={nhanVien.TenChucVu} />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="TenPhong" value="Tên Phòng" />
          </div>
          <TextInput id="TenPhong" type="text" value={nhanVien.TenPhong} />
        </div>
      </form>
    </div>
  );
}
