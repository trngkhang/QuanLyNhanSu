import { Button, Label, Select, TextInput } from "flowbite-react";
import { useNavigate } from "react-router-dom";
import { useState } from "react";

export default function ThemNhanVien() {
  const [formData, setFormData] = useState({});
  const navigate = useNavigate();

  console.log(formData);
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch("/api/nhanvien/themnhanvien", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });
      const data = await res.json();
      console.log(data);
      if (res.ok) {
        navigate(`/dashboard?tab=nhansu`);
      }
    } catch (error) {
      setPublishErorr(error.message);
    }
  };
  return (
    <div className="min-h-screen max-w-3xl mx-auto p-3">
      <h1 className=" text-3xl font-semibold text-center py-7">
        Tạo mới nhân viên
      </h1>

      <form onSubmit={handleSubmit} className="flex max-w-md flex-col gap-4">
        <div>
          <div className="mb-2 block">
            <Label htmlFor="HoTen" value="Họ tên" />
          </div>
          <TextInput
            id="HoTen"
            type="text"
            required
            maxLength={100}
            placeholder="Họ tên"
            onChange={(e) =>
              setFormData({ ...formData, HoTen: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="GioiTinh" value="Giới tính" />
          </div>
          <TextInput
            id="GioiTinh"
            type="text"
            maxLength={3}
            required
            placeholder="Giới tính"
            onChange={(e) =>
              setFormData({ ...formData, GioiTinh: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="NgaySinh" value="Ngày sinh" />
          </div>
          <TextInput
            id="NgaySinh"
            type="date"
            required
            placeholder="Họ tên"
            onChange={(e) =>
              setFormData({ ...formData, NgaySinh: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="SoDienThoai" value="Số điện thoại" />
          </div>
          <TextInput
            id="SoDienThoai"
            type="number"
            maxLength={15}
            required
            placeholder="SĐT"
            onChange={(e) =>
              setFormData({ ...formData, SoDienThoai: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="Luong" value="Lương" />
          </div>
          <TextInput
            id="Luong"
            type="number"
            maxLength={9}
            required
            placeholder="Lương"
            onChange={(e) =>
              setFormData({ ...formData, Luong: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="PhuCap" value="Phụ cấp" />
          </div>
          <TextInput
            id="PhuCap"
            type="number"
            maxLength={9}
            required
            placeholder="Phụ cấp"
            onChange={(e) =>
              setFormData({ ...formData, PhuCap: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="MaSoThue" value="Mã số thuế" />
          </div>
          <TextInput
            id="MaSoThue"
            type="text"
            maxLength={20}
            required
            placeholder="Mã số thuế"
            onChange={(e) =>
              setFormData({ ...formData, MaSoThue: e.target.value })
            }
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="TenChucVu" value="Tên chức vụ" />
          </div>
          <Select
            id="TenChucVu"
            onChange={(e) => {
              setFormData({ ...formData, MaChucVu: e.target.value });
            }}
          >
            <option value="1">Nhân viên</option>
            <option value="2">Trưởng phòng</option>
            <option value="3">Nhân viên phòng nhân sự</option>
            <option value="4">Trưởng phòng nhân sự</option>
            <option value="5">Nhân viên phòng tài vụ</option>
            <option value="6">Giám đốc</option>
          </Select>
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="TenPhong" value="Tên chức vụ" />
          </div>
          <Select
            id="TenPhong"
            onChange={(e) => {
              setFormData({ ...formData, MaPhong: e.target.value });
            }}
          >
            <option value="100">Phòng IT</option>
            <option value="101">Phòng nhân sự</option>
            <option value="102">Phòng tài vụ</option>
            <option value="103">Phòng giám đốc</option>
          </Select>
        </div>
        {/* <div>
          <div className="mb-2 block">
            <Label htmlFor="TenChucVu" value="Tên chức vụ" />
          </div>
          <TextInput
            id="TenChucVu"
            type="text"
            maxLength={9}
            required
            placeholder="Tên chức vụ"
            value={nhanVien ? nhanVien.TenChucVu : "Lỗi"}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="TenPhong" value="Tên phòng" />
          </div>
          <TextInput
            id="TenPhong"
            type="text"
            maxLength={20}
            required
            placeholder="Tên phòng"
            value={nhanVien ? nhanVien.TenPhong : "Lỗi"}
          />
        </div> */}
        <Button type="submit" gradientDuoTone="greenToBlue">
          Cập nhật
        </Button>
      </form>
    </div>
  );
}
