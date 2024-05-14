import { Avatar, Button, Dropdown, Navbar, TextInput } from "flowbite-react";
import { Link, useLocation } from "react-router-dom";
import { AiOutlineSearch } from "react-icons/ai";
import { FaMoon } from "react-icons/fa";
import { useSelector, useDispatch } from "react-redux";
import { signoutSuccess } from "../redux/user/userSlice";

export default function Header() {
  const path = useLocation().pathname;
  const dispatch = useDispatch();
  const { nhanVien } = useSelector((state) => state.user);

  const handleSignout = async () => {
    try {
      const res = await fetch("/api/auth/dangxuat", {
        method: "POST",
      });
      const data = res.json();
      console.log(res.ok);
      if (!res.ok) {
        console.log(data.message);
      } else {
        dispatch(signoutSuccess());
      }
    } catch (error) {
      console.log(error.message);
    }
  };

  return (
    <Navbar className="border-b-2">
      <Link
        to="/"
        className="self-center whitespace-nowrap text-sm sm:text-xl font-semibold dark:text-white"
      >
        <span className="px-2 py-1 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 rounded-lg text-white">
          Nhóm 6
        </span>
        Quản lý nhân sự
      </Link>
      <form>
        <TextInput
          type="text"
          placeholder="Search..."
          rightIcon={AiOutlineSearch}
          className="hidden lg:inline"
        />
      </form>
      <Button className="w-12 h-10 lg:hidden" color="gray" pill>
        <AiOutlineSearch />
      </Button>
      <div className="flex gap-2 md:order-2">
        <Button className="w-12 h-10 hidden sm:inline" color="gray" pill>
          <FaMoon />
        </Button>
        {nhanVien ? (
          <Dropdown
            arrowIcon={false}
            inline
            label={
              <Avatar
                alt="user"
                img="https://i.pinimg.com/564x/89/90/48/899048ab0cc455154006fdb9676964b3.jpg"
                rounded
              />
            }
          >
            <Dropdown.Header className=" min-w-40">
              <span className="block text-sm">@{nhanVien.MaNV}</span>
              <span className="block text-sm font-medium truncate">
                {nhanVien.HoTen}
              </span>
            </Dropdown.Header>
            {/* <Link to={"/dashboard?tab=profile"}>
              <Dropdown.Item>Profile</Dropdown.Item>
            </Link> */}
            <Dropdown.Divider />
            <Dropdown.Item onClick={handleSignout}>Đăng xuất</Dropdown.Item>
          </Dropdown>
        ) : (
          <Link to="/dangnhap">
            <Button gradientDuoTone="purpleToBlue" outline>
              Đăng nhập
            </Button>
          </Link>
        )}
        <Navbar.Toggle />
      </div>
      <Navbar.Collapse>
        <Navbar.Link active={path === "/"} as={"div"}>
          <Link to="/">Home</Link>
        </Navbar.Link>
        <Navbar.Link active={path === "/about"} as={"div"}>
          <Link to="/about">About</Link>
        </Navbar.Link>
      </Navbar.Collapse>
    </Navbar>
  );
}
