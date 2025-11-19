import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { registerAdmin } from "../services/authService";
import InputField from "../components/InputField";
import { Link } from "react-router-dom";
import { validateEmail, validatePassword, validateConfirmPassword } from "../utils/validation";
import { toast } from 'react-hot-toast';

export default function Register() {

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const [emailError, setEmailError] = useState("");
    const [passwordError, setPasswordError] = useState("");
    const [confirmPasswordError, setConfirmPasswordError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();

        setError("")
        setEmailError("");
        setPasswordError("");
        setConfirmPasswordError("");

        let hasError = false;

        const emailErrorMsg = validateEmail(email);
        const passwordErrorMsg = validatePassword(password);
        const confirmErrorMsg = validateConfirmPassword(password, confirmPassword);

        if (emailErrorMsg) {
            setEmailError(emailErrorMsg);
            hasError = true;
        }

        if (passwordErrorMsg) {
            setPasswordError(passwordErrorMsg);
            hasError = true;
        }

        if (confirmErrorMsg) {
            setConfirmPasswordError(confirmErrorMsg);
            hasError = true;
        }

        if (hasError) {
            setLoading(false); // đảm bảo reset loading
            return;
        }

        setLoading(true);
        try {
            await registerAdmin(email, password);
            toast.success("Registerd Successfully!", {
                icon: "✅",
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
            navigate("/");
        } catch (err) {
            if (err.code === "auth/email-already-in-use") {
                setError("This email is already in use.");
            } else if (err.code === "auth/invalid-email") {
                setError("Invalid email address.");
            } else if (err.code === "auth/weak-password") {
                setError("Password is too weak.");
            } else {
                toast.error("An error occurred, please try again.", {
                    duration: 3000,
                    position: "top-right",
                    icon: "❌"
                });
                console.log(err);
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-white px-6 py-12">

            <div className="w-full max-w-md bg-white shadow-md rounded-2xl p-8">
                {/* Logo + tiêu đề */}
                <div className="sm:mx-auto sm:w-full sm:max-w-sm">
                    <img
                        src="https://cdn-icons-png.flaticon.com/512/838/838646.png"
                        alt="Logo"
                        className="mx-auto h-25 w-auto"
                    />
                    <h2 className="mt-10 text-center text-2xl font-bold tracking-tight text-gray-900">
                        Create your account
                    </h2>
                </div>

                {/* Form register */}
                <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && <p className="text-red-500 text-sm text-center">{error}</p>}

                        {/* Email */}
                        <div>
                            <label htmlFor="email" className="block text-sm font-medium text-gray-700 text-left">
                                Email address
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="email"
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="Enter your email"
                                    autoComplete="email"
                                />
                            </div>
                            {emailError && <p className="text-red-500 text-sm mt-1 text-left">{emailError}</p>}
                        </div>

                        {/* Password */}
                        <div>
                            <label htmlFor="password" className="block text-sm font-medium text-gray-700 text-left">
                                Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="password"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="Enter your password"
                                    isPassword={true}
                                    autoComplete="new-password"
                                />
                            </div>
                            {passwordError && <p className="text-red-500 text-sm mt-1 text-left">{passwordError}</p>}
                        </div>

                        {/* Confirm Password */}
                        <div>
                            <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 text-left">
                                Confirm Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="confirmPassword"
                                    value={confirmPassword}
                                    onChange={(e) => setConfirmPassword(e.target.value)}
                                    placeholder="Confirm your password"
                                    isPassword={true}
                                    autoComplete="new-password"
                                />
                            </div>
                            {confirmPasswordError && <p className="text-red-500 text-sm mt-1 text-left">{confirmPasswordError}</p>}
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
                                    "Register"
                                )}
                            </button>
                        </div>
                    </form>

                    <p className="mt-10 text-center text-sm text-gray-500">
                        Already have an account?{" "}
                        <Link
                            to="/"
                            className="font-semibold text-indigo-500 hover:text-indigo-400"
                        >
                            Sign in
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}