import { Button, Modal, Table } from "flowbite-react";
import { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { Link } from "react-router-dom";
import { HiOutlineExclamationCircle } from "react-icons/hi";

export default function DashNhanSu() {
  const [nhanVien, setNhanVien] = useState([]);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const res = await fetch("/api/nhanvien/tatcanhanvien");
        const data = await res.json();
        console.log(data);
        if (res.ok) {
          setNhanVien(data);
        }
      } catch (error) {
        console.log(error.message);
      }
    };
    fetchUsers();
  }, []);

  return (
    <div className="table-auto overflow-x-scroll md:mx-auto p-3 scrollbar scrollbar-track-slate-100 scrollbar-thumb-slate-300 dark:scrollbar-track-slate-700 dark:scrollbar-thumb-slate-500">
      <Table hoverable className="shadow-md">
        <Table.Head>
          <Table.HeadCell>STT</Table.HeadCell>
          <Table.HeadCell>Mã nhân viên</Table.HeadCell>
          <Table.HeadCell>Họ tên</Table.HeadCell>
          <Table.HeadCell>Giới tính</Table.HeadCell>
          <Table.HeadCell>Ngày sinh</Table.HeadCell>
          <Table.HeadCell>SĐT</Table.HeadCell>
          <Table.HeadCell>Lương</Table.HeadCell>
          <Table.HeadCell>Phụ cấp</Table.HeadCell>
          <Table.HeadCell>Mã số thuế</Table.HeadCell>
          <Table.HeadCell>Edit</Table.HeadCell>
        </Table.Head>
        <Table.Body className="divide-y">
          {nhanVien.map((nv, index) => (
            <Table.Row
              key={`${nv.MaNV}-${index}`}
              className="bg-white dark:border-gray-700 dark:bg-gray-800"
            >
              <Table.Cell>{index + 1}</Table.Cell>
              <Table.Cell>{nv.MaNV ? nv.MaNV : "đã ẩn"}</Table.Cell>

              <Table.Cell>{nv.HoTen ? nv.HoTen : "đã ẩn"}</Table.Cell>
              <Table.Cell>{nv.GioiTinh ? nv.GioiTinh : "đã ẩn"}</Table.Cell>
              <Table.Cell>
                {nv.NgaySinh
                  ? new Date(nv.NgaySinh).toLocaleDateString()
                  : "đã ẩn"}
              </Table.Cell>
              <Table.Cell>
                {nv.SoDienThoai ? nv.SoDienThoai : "đã ẩn"}
              </Table.Cell>
              <Table.Cell>{nv.Luong ? nv.Luong : "đã ẩn"}</Table.Cell>
              <Table.Cell>{nv.PhuCap ? nv.PhuCap : "đã ẩn"}</Table.Cell>
              <Table.Cell>{nv.MaSoThue ? nv.MaSoThue : "đã ẩn"}</Table.Cell>
              <Table.Cell>
                <Link
                  to={`/suanhanvien/${nv.MaNV}`}
                  className="text-teal-500 hover:underline"
                >
                  Sửa
                </Link>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table.Body>
      </Table>
    </div>
  );
}