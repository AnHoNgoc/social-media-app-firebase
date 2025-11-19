import { useEffect, useState } from "react";
import { getUsers, deleteUserFull } from "../services/userService";
import { FaTrashAlt, FaPen } from "react-icons/fa";
import CustomModal from "../components/CustomModal";
import FormUser from "../components/FormUser";
import { toast } from 'react-hot-toast';

export default function Users() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [modalType, setModalType] = useState(null); // "edit" | "delete"
    const [selectedUser, setSelectedUser] = useState(null);

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        setLoading(true);
        try {
            const data = await getUsers();
            setUsers(data);
        } catch (error) {
            console.error("Failed to fetch users:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        try {
            await deleteUserFull(id);
            await fetchUsers();
            closeModal();

            toast.success("User deleted successfully!", {
                icon: "🗑️",
                style: {
                    background: "#10B981",
                    color: "#fff",
                    padding: "16px 24px",
                    borderRadius: "0.5rem",
                    fontWeight: "600",
                    boxShadow: "0 4px 14px rgba(0,0,0,0.1)",
                    fontSize: "16px",
                },
                position: "top-right",
                autoClose: 3000,
            });
        } catch (error) {
            console.error("Failed to delete user:", error);

            toast.error("Failed to delete user. Please try again.", {
                icon: "⚠️",
                style: {
                    background: "#EF4444",
                    color: "#fff",
                    padding: "16px 24px",
                    borderRadius: "0.5rem",
                    fontWeight: "600",
                    boxShadow: "0 4px 14px rgba(0,0,0,0.1)",
                    fontSize: "16px",
                },
                position: "top-right",
                autoClose: 3000,
            });
        }
    };

    const handleSaveUser = (updatedUser) => {
        setUsers((prev) =>
            prev.map((u) => (u.id === updatedUser.id ? updatedUser : u))
        );
        closeModal();
    };

    const openEditModal = (user) => {
        setSelectedUser(user);
        setModalType("edit");
    };

    const openDeleteModal = (user) => {
        setSelectedUser(user);
        setModalType("delete");
    };

    const closeModal = () => {
        setSelectedUser(null);
        setModalType(null);
    };

    if (loading) {
        return (
            <div className="flex justify-center items-center h-64">
                <div className="w-12 h-12 border-4 border-blue-500 border-dashed rounded-full animate-spin"></div>
            </div>
        );
    }

    return (
        <div className="flex flex-col min-h-screen dark:bg-gray-800">
            <div className="max-w-7xl mx-auto w-full p-6">
                <h1 className="text-2xl font-bold mb-6 text-gray-800 dark:text-white">
                    User List
                </h1>

                {/* Table Users */}
                <div className="overflow-x-auto shadow-lg rounded-lg border border-gray-200 dark:border-gray-700">
                    <table className="min-w-full text-sm text-left text-gray-600 dark:text-gray-300">
                        <thead className="bg-gray-50 dark:bg-gray-800 text-gray-700 dark:text-gray-200 uppercase text-xs font-semibold">
                            <tr>
                                <th className="px-6 py-3">Email</th>
                                <th className="px-6 py-3">Role</th>
                                <th className="px-6 py-3 text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                            {users.map((user, idx) => (
                                <tr
                                    key={user.id}
                                    className={`transition-colors duration-200 ${idx % 2 === 0
                                        ? "bg-white dark:bg-gray-700"
                                        : "bg-gray-50 dark:bg-gray-800"
                                        } hover:bg-blue-50 dark:hover:bg-blue-900`}
                                >
                                    <td className="px-6 py-3 font-medium">{user.email}</td>
                                    <td className="px-6 py-3 capitalize">{user.role}</td>
                                    <td className="px-6 py-3 text-center">
                                        <div className="flex justify-center items-center gap-4">
                                            {/* Edit */}
                                            <button
                                                onClick={() => openEditModal(user)}
                                                className="p-2 rounded-full hover:bg-yellow-100 dark:hover:bg-yellow-800 transition"
                                                title="Edit"
                                            >
                                                <FaPen className="text-yellow-500 hover:text-yellow-700" size={16} />
                                            </button>

                                            {/* Delete */}
                                            <button
                                                onClick={() => openDeleteModal(user)}
                                                className="p-2 rounded-full hover:bg-red-100 dark:hover:bg-red-800 transition"
                                                title="Delete"
                                            >
                                                <FaTrashAlt className="text-red-500 hover:text-red-700" size={16} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                            {users.length === 0 && (
                                <tr>
                                    <td colSpan="3" className="text-center py-6 text-gray-400 dark:text-gray-500">
                                        No users found.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal Delete */}
            <CustomModal
                open={selectedUser && modalType === "delete"}
                title={`Delete user ${selectedUser?.email}?`}
                confirmText="Delete"
                cancelText="Cancel"
                onConfirm={async () => {
                    await handleDelete(selectedUser.id);
                }}
                onClose={closeModal}
            >
                Are you sure you want to delete this user?
            </CustomModal>

            {/* Modal Edit */}
            {selectedUser && modalType === "edit" && (
                <FormUser
                    user={selectedUser}
                    onSave={handleSaveUser}
                    onClose={closeModal}
                />
            )}
        </div>
    );
}