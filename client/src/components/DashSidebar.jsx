import { Sidebar } from "flowbite-react";
import { HiUser, HiArrowSmRight, HiUserGroup } from "react-icons/hi";
import { useEffect, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { HiMiniUserPlus } from "react-icons/hi2";

export default function DashSidebar() {
  const dispatch = useDispatch();
  const { nhanVien } = useSelector((state) => state.user);
  const tenChucVu = nhanVien.TenChucVu;

  const location = useLocation();
  const [tab, setTab] = useState("");
  useEffect(() => {
    const urlParams = new URLSearchParams(location.search);
    const tabFromUrl = urlParams.get("tab");
    if (tabFromUrl) {
      setTab(tabFromUrl);
    }
  }, [location.search]);
  return (
    <Sidebar className="w-full md:w-56">
      <Sidebar.Items>
        <Sidebar.ItemGroup>
          <Link to="/dashboard?tab=profile">
            <Sidebar.Item
              active={tab === "profile"}
              icon={HiUser}
              label={tenChucVu}
              labelColor="dark"
              as="div"
            >
              Thông tin cá nhân
            </Sidebar.Item>
          </Link>
          <Link to="/dashboard?tab=nhansu">
            <Sidebar.Item
              icon={HiUserGroup}
              className="cursor-pointer"
              as="div"
            >
              Danh sách nhân viên
            </Sidebar.Item>
          </Link>

          {tenChucVu === "Nhân viên phòng nhân sự" && (
            <Link to="/themnhanvien">
              <Sidebar.Item
                icon={HiMiniUserPlus}
                className="cursor-pointer"
                as="div"
              >
                Tạo mới nhân viên
              </Sidebar.Item>
            </Link>
          )}
        </Sidebar.ItemGroup>
      </Sidebar.Items>
    </Sidebar>
  );
}
