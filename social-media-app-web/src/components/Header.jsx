import { useState } from "react";
import { logoutAdmin } from "../services/authService";
import CustomModal from "../components/CustomModal";
import { FaSignOutAlt, FaKey } from "react-icons/fa";
import { useNavigate } from "react-router-dom";

const Header = () => {
    const [logoutModalOpen, setLogoutModalOpen] = useState(false);
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            await logoutAdmin();
            navigate("/"); // quay về trang login
        } catch (error) {
            console.error("Logout failed:", error);
        }
    };

    return (
        <header className="w-full bg-white dark:bg-gray-800 shadow-sm sticky top-0 z-50">
            <div className="max-w-7xl mx-auto flex justify-between items-center px-6 py-3">
                {/* Logo */}
                <div className="flex items-center space-x-4">
                    <img
                        src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWuSD6W63srYdPeltD76ffOvQ1kAFZP-5sVg&s"
                        className="h-10 sm:h-12" // tăng kích thước logo
                        alt="Logo"
                    />
                    <span className="text-2xl font-bold text-gray-800 dark:text-white">
                        Social Media
                    </span>
                </div>
                {/* 
                {/* User menu */}
                <div className="flex items-center space-x-6">
                    {/* Change Password */}
                    <div
                        className="flex items-center space-x-2 cursor-pointer group"
                        onClick={() => navigate("/change-password")}
                        title="Change Password"
                    >
                        <FaKey
                            className="text-gray-700 dark:text-gray-300 group-hover:text-indigo-500 transition"
                            size={20}
                        />
                        <span className="text-l text-gray-800 dark:text-white group-hover:text-indigo-500 transition">
                            Change Password
                        </span>
                    </div>

                    {/* Logout */}
                    <div
                        className="flex items-center space-x-2 cursor-pointer group"
                        onClick={() => setLogoutModalOpen(true)}
                        title="Logout"
                    >
                        <FaSignOutAlt
                            className="text-gray-700 dark:text-gray-300 group-hover:text-red-500 transition"
                            size={22}
                        />
                        <span className="text-l text-gray-800 dark:text-white group-hover:text-red-500 transition">
                            Logout
                        </span>
                    </div>
                </div>

                {/* Logout confirmation modal */}
                {logoutModalOpen && (
                    <CustomModal
                        open={logoutModalOpen}
                        onClose={() => setLogoutModalOpen(false)}
                        title="Confirm Logout"
                        confirmText="Logout"
                        cancelText="Cancel"
                        onConfirm={handleLogout}
                    >
                        Are you sure you want to logout?
                    </CustomModal>
                )}
            </div>
        </header>
    );
};

export default Header;