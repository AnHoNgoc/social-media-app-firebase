import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginAdmin } from "../services/authService";
import InputField from "../components/InputField";
import { Link } from "react-router-dom";
import { validateEmail, validatePassword } from "../utils/validation";



export default function Login() {

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const [emailError, setEmailError] = useState("");
    const [passwordError, setPasswordError] = useState("");
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);

        setError("");
        setEmailError("");
        setPasswordError("");

        let hasError = false;

        const emailErrorMsg = validateEmail(email);
        const passwordErrorMsg = validatePassword(password);

        if (emailErrorMsg) {
            setEmailError(emailErrorMsg);
            hasError = true;
        }

        if (passwordErrorMsg) {
            setPasswordError(passwordErrorMsg);
            hasError = true;
        }

        if (hasError) {
            setLoading(false); // đảm bảo reset loading
            return;
        }

        try {
            await loginAdmin(email, password);
            navigate("/dashboard");
        } catch (err) {

            // Nếu có message chứa 'Access denied', là lỗi role
            if (err.message && err.message.includes("Access denied")) {
                setError("Access denied. Admins only.");
            }
            // Nếu err.code tồn tại, là lỗi Firebase Auth
            else if (err.code) {
                setError("Invalid email or password.");
            }
            // Các lỗi khác
            else {
                setError("An error occurred. Please try again.");
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-white px-6 py-12">


            {/* Logo + tiêu đề */}
            <div className="w-full max-w-md bg-white shadow-md rounded-2xl p-8">
                {/* Logo + tiêu đề */}
                <div className="sm:mx-auto sm:w-full sm:max-w-sm">
                    <img
                        src="https://cdn-icons-png.flaticon.com/512/838/838646.png"
                        alt="Logo"
                        className="mx-auto h-25 w-auto"
                    />
                    <h2 className="mt-10 text-center text-2xl font-bold tracking-tight text-gray-900">
                        Sign in to your account
                    </h2>
                </div>

                {/* Form login */}
                <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {error && <p className="text-red-500 text-sm text-center">{error}</p>}

                        <div>
                            <label
                                htmlFor="email"
                                className="block text-sm font-medium text-gray-700 text-left"
                            >
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

                        <div className="mb-4">
                            <label
                                htmlFor="password"
                                className="block text-sm font-medium text-gray-700 text-left"
                            >
                                Password
                            </label>
                            <div className="mt-2">
                                <InputField
                                    id="password"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="Enter your password"
                                    isPassword={true}
                                    autoComplete="current-password"
                                />
                            </div>
                            {passwordError && <p className="text-red-500 text-sm mt-1 text-left">{passwordError}</p>}
                            <div className="mt-1 text-right">
                                <Link
                                    to="/forgot-password"
                                    className="text-sm font-semibold text-indigo-500 hover:text-indigo-400"
                                >
                                    Forgot password?
                                </Link>
                            </div>
                        </div>

                        <div>
                            <button
                                type="submit"
                                className="flex w-full justify-center items-center rounded-md bg-indigo-500 px-3 py-1.5 text-sm font-semibold text-white hover:bg-indigo-400"
                                disabled={loading} // disable button khi loading
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
                                    "Sign in"
                                )}
                            </button>
                        </div>
                    </form>

                    <p className="mt-10 text-center text-sm text-gray-500">
                        Not a member yet?{" "}
                        <Link
                            to="/register"
                            className="font-semibold text-indigo-500 hover:text-indigo-400"
                        >
                            Create an account
                        </Link>
                    </p>
                </div>
            </div>
        </div>
    );
}