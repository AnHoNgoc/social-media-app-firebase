import { useState, useEffect } from "react";
import { createPortal } from "react-dom";
import { updateUser } from "../services/userService";

export default function FormUser({ user, onSave, onClose }) {
    const [email, setEmail] = useState("");
    const [role, setRole] = useState("user");
    const [saving, setSaving] = useState(false);

    useEffect(() => {
        if (user) {
            setEmail(user.email || "");
            setRole(user.role || "customer");
        }
    }, [user]);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);

        try {
            await updateUser(user.id, { email, role });
            onSave && onSave({ ...user, email, role });
            onClose && onClose();
        } catch (error) {
            console.error("Failed to save user:", error);
        } finally {
            setSaving(false);
        }
    };

    return createPortal(
        <div
            className="fixed inset-0 bg-black/50 z-50 flex justify-center items-center p-4"
            onClick={onClose}
        >
            <div
                className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 w-full max-w-md relative"
                onClick={(e) => e.stopPropagation()}
            >
                <h2 className="text-2xl font-bold mb-6 text-gray-800 dark:text-white text-center">
                    Edit User
                </h2>

                <form onSubmit={handleSubmit} className="space-y-5">
                    {/* Email */}
                    <div className="flex flex-col">
                        <label className="mb-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                            Email
                        </label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white transition"
                            required
                            disabled={saving}
                        />
                    </div>

                    {/* Role */}
                    <div className="flex flex-col">
                        <label className="mb-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                            Role
                        </label>
                        <select
                            value={role}
                            onChange={(e) => setRole(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:text-white transition"
                            disabled={saving}
                        >
                            <option value="user">User</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>

                    {/* Buttons */}
                    <div className="flex justify-end gap-4 mt-6">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-5 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 transition"
                            disabled={saving}
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="px-5 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 dark:hover:bg-blue-500 transition"
                            disabled={saving}
                        >
                            {saving ? "Saving..." : "Save"}
                        </button>
                    </div>
                </form>
            </div>
        </div>,
        document.body
    );
}