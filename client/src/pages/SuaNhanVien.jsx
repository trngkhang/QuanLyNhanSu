import { Button, Label, TextInput } from "flowbite-react";
import { Link, useParams } from "react-router-dom";
import { useEffect, useState } from "react";

export default function SuaNhanVien() {
  const { nhanvienId } = useParams();
  console.log(useParams());
  console.log("nhanvienId", nhanvienId);
  const [nhanVien, setNhanVien] = useState(null);
  const [formData, setFormData] = useState({});
  useEffect(() => {
    const fetchPost = async () => {
      try {
        const res = await fetch(
          `/api/nhanvien/motnhanvien?nhanvienId=${nhanvienId}`
        );
        const data = await res.json();
        console.log("dataaaa", data);
        setNhanVien(data);
      } catch (error) {}
    };
    fetchPost();
  }, [nhanvienId]);
  console.log(formData);
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch(
        `/api/post/updatepost/${formData._id}/${currentUser._id}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(formData),
        }
      );
      const data = await res.json();
      console.log(data);
      if (!res.ok) {
        setPublishErorr(data.message);
        return;
      }
      if (res.ok) {
        setPublishErorr(null);
        navigate(`/post/${data.slug}`);
      }
    } catch (error) {
      setPublishErorr(error.message);
    }
  };
  return (
    <div className="min-h-screen max-w-3xl mx-auto p-3">
      <h1 className=" text-3xl font-semibold text-center py-7">
        Chỉnh sửa thông tin nhân viên
      </h1>

      <form onSubmit={handleSubmit} className="flex max-w-md flex-col gap-4">
        <div>
          <div className="mb-2 block">
            <Label htmlFor="MaNV" value="Mã nhân viên" />
          </div>
          <TextInput
            id="MaNV"
            type="number"
            required
            placeholder="Mã nhân viên"
            disabled
            value={nhanVien ? nhanVien.MaNhanVien : "Lỗi"}
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
            maxLength={100}
            placeholder="Họ tên"
            value={nhanVien ? nhanVien.HoTen : "Lỗi"}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="Phai" value="Giới tính" />
          </div>
          <TextInput
            id="Phai"
            type="text"
            maxLength={3}
            required
            placeholder="Giới tính"
            value={nhanVien ? nhanVien.GioiTinh : "Lỗi"}
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
            placeholder="Họ tên"
            value={nhanVien ? nhanVien.HoTen : "Lỗi"}
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
            value={nhanVien ? nhanVien.SoDienThoai : "Lỗi"}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="Luong" value="Lương" />
          </div>
          <TextInput
            id="Luong"
            type="int"
            maxLength={9}
            required
            placeholder="Lương"
            value={nhanVien ? nhanVien.Luong : "Lỗi"}
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="PhuCap" value="Phụ cấp" />
          </div>
          <TextInput
            id="PhuCap"
            type="int"
            maxLength={9}
            required
            placeholder="Phụ cấp"
            value={nhanVien ? nhanVien.PhuCap : "Lỗi"}
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
            value={nhanVien ? nhanVien.MaSoThue : "Lỗi"}
            onChange={(value) => setFormData({ ...formData, MaSoThue: value })}
          />
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
