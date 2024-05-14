import { Button, Checkbox, Label, TextInput } from "flowbite-react";

export default function SuaNhanVien() {
  return (
    <div className="min-h-screen max-w-3xl mx-auto p-3">
      <h1 className=" text-3xl font-semibold text-center py-7">
        Chỉnh sửa thông tin nhân viên
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
            placeholder="Mã nhân viên"
            disabled
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
          />
        </div>
        <div>
          <div className="mb-2 block">
            <Label htmlFor="NgaySinh" value="Ngày sinh" />
          </div>
          <TextInput id="NgaySinh" type="date" required placeholder="Họ tên" />
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
          />
        </div>

        <Button type="submit" gradientDuoTone="greenToBlue">
          Cập nhật
        </Button>
      </form>
    </div>
  );
}
