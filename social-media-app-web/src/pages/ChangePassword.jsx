import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { changePassword } from "../services/authService";
import InputField from "../components/InputField";
import { toast } from "react-hot-toast";
import { validatePassword, validateNewPassword, validateConfirmPassword } from "../utils/validation";

export default function ChangePassword() {
    const [currentPassword, setCurrentPassword] = useState("");
    const [newPassword, setNewPassword] = useState("");
    const [confirmNewPassword, setConfirmNewPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const [currentPasswordError, setCurrentPasswordError] = useState("");
    const [newPasswordError, setNewPasswordError] = useState("");
    const [confirmNewPasswordError, setConfirmNewPasswordError] = useState("");

    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();

        setError("");
        setCurrentPasswordError("");
        setNewPasswordError("");
        setConfirmNewPasswordError("");

        let hasError = false;

        const currentErrorMsg = validatePassword(currentPassword);
        const newErrorMsg = validateNewPassword(currentPassword, newPassword);
        const confirmErrorMsg = validateConfirmPassword(newPassword, confirmNewPassword);

        if (currentErrorMsg) {
            setCurrentPasswordError(currentErrorMsg);
            hasError = true;
        }

        if (newErrorMsg) {
            setNewPasswordError(newErrorMsg);
            hasError = true;
        }

        if (confirmErrorMsg) {
            setConfirmNewPasswordError(confirmErrorMsg);
            hasError = true;
        }

        if (hasError) {
            setLoading(false);
            return;
        }

        setLoading(true);
        try {
            await changePassword(currentPassword, newPassword);
            toast.success("Password changed successfully!", {
                icon: "🔒",
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
                duration: 3000,
            });
            navigate(-1); // hoặc navigate(-1) để quay lại trang trước
        } catch (err) {
            console.error(err);
            if (err.code === "auth/invalid-credential" || err.code === "auth/wrong-password") {
                setError("Incorrect current password.");
            } else if (err.code === "auth/weak-password") {
                setError("New password is too weak.");
            } else if (err.code === "auth/requires-recent-login") {
                setError("Please log in again to change your password.");
            } else {
                toast.error("An error occurred, please try again.", {
                    duration: 3000,
                    position: "top-right",
                    icon: "❌"
                });
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-white px-6 py-12">
            <div className="w-full max-w-md bg-white shadow-md rounded-2xl p-8">
                <div className="sm:mx-auto sm:w-full sm:max-w-sm">
                    <img
                        src="https://cdn-icons-png.flaticon.com/512/838/838646.png"
                        alt="Logo"
                        className="mx-auto h-25 w-auto"
                    />
                    <h2 className="mt-10 text-center text-2xl font-bold tracking-tight text-gray-900">
                        Change Password
                    </h2>
                </div>

                <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && <p className="text-red-500 text-sm text-center">{error}</p>}

                        {/* Current Password */}
                        <div>
                            <label htmlFor="currentPassword" className="block text-sm font-medium text-gray-700 text-left">
                                Current Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="currentPassword"
                                    value={currentPassword}
                                    onChange={(e) => setCurrentPassword(e.target.value)}
                                    placeholder="Enter your current password"
                                    isPassword={true}
                                    autoComplete="current-password"
                                />
                            </div>
                            {currentPasswordError && (
                                <p className="text-red-500 text-sm mt-1 text-left">{currentPasswordError}</p>
                            )}
                        </div>

                        {/* New Password */}
                        <div>
                            <label htmlFor="newPassword" className="block text-sm font-medium text-gray-700 text-left">
                                New Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="newPassword"
                                    value={newPassword}
                                    onChange={(e) => setNewPassword(e.target.value)}
                                    placeholder="Enter your new password"
                                    isPassword={true}
                                    autoComplete="new-password"
                                />
                            </div>
                            {newPasswordError && (
                                <p className="text-red-500 text-sm mt-1 text-left">{newPasswordError}</p>
                            )}
                        </div>

                        {/* Confirm New Password */}
                        <div>
                            <label htmlFor="confirmNewPassword" className="block text-sm font-medium text-gray-700 text-left">
                                Confirm New Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="confirmNewPassword"
                                    value={confirmNewPassword}
                                    onChange={(e) => setConfirmNewPassword(e.target.value)}
                                    placeholder="Confirm your new password"
                                    isPassword={true}
                                    autoComplete="new-password"
                                />
                            </div>
                            {confirmNewPasswordError && (
                                <p className="text-red-500 text-sm mt-1 text-left">{confirmNewPasswordError}</p>
                            )}
                        </div>

                        <div>
                            <button
                                type="submit"
                                className="flex w-full justify-center items-center rounded-md bg-indigo-500 px-3 py-1.5 text-sm font-semibold text-white hover:bg-indigo-400"
                                disabled={loading}
                            >
                                {loading ? (
                                    <svg
                                        className="animate-spin h-5 w-5 text-white"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                    >
                                        <circle
                                            className="opacity-25"
                                            cx="12"
                                            cy="12"
                                            r="10"
                                            stroke="currentColor"
                                            strokeWidth="4"
                                        ></circle>
                                        <path
                                            className="opacity-75"
                                            fill="currentColor"
                                            d="M4 12a8 8 0 018-8v8H4z"
                                        ></path>
                                    </svg>
                                ) : (
                                    "Change Password"
                                )}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
}