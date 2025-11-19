import { useState } from "react";
import { sendPasswordReset } from "../services/authService";
import { Link } from "react-router-dom";
import { validateEmail } from "../utils/validation";

export default function ForgotPassword() {

    const [email, setEmail] = useState("");
    const [message, setMessage] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const [emailError, setEmailError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);

        setMessage("");
        setError("");
        setEmailError("");


        let hasError = false;

        const emailErrorMsg = validateEmail(email);


        if (emailErrorMsg) {
            setEmailError(emailErrorMsg);
            hasError = true;
        }


        if (hasError) {
            setLoading(false);
            return;
        }

        try {
            await sendPasswordReset(email);
            setMessage("If the email exists in our system, a reset link has been sent.");
        } catch (err) {
            console.log("Forgot password error:", err);

            if (err.code === "auth/invalid-email") {
                setError("Invalid email address.");
            } else {
                setError("Failed to send reset link. Please try again later.");
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-white px-6 py-12">

            <div className="w-full max-w-md bg-white shadow-md rounded-2xl p-8">
                {/* Logo + Title */}
                <div className="sm:mx-auto sm:w-full sm:max-w-sm">
                    <img
                        src="https://cdn-icons-png.flaticon.com/512/838/838646.png"
                        alt="Logo"
                        className="mx-auto h-25 w-auto"
                    />
                    <h2 className="mt-10 text-center text-2xl font-bold tracking-tight text-gray-900">
                        Forgot your password?
                    </h2>
                    <p className="mt-2 text-center text-sm text-gray-600">
                        Enter your email to receive a reset link.
                    </p>
                </div>

                {/* Form */}
                <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {message && <p className="text-green-500 text-sm">{message}</p>}
                        {error && <p className="text-red-500 text-sm">{error}</p>}

                        <div>
                            <label
                                htmlFor="email"
                                className="block text-sm font-medium text-gray-700 text-left"
                            >
                                Email address
                            </label>
                            <div className="mt-2">
                                <input
                                    id="email"
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="Enter your email"
                                    className="block w-full rounded-md bg-gray-100 px-3 py-1.5 text-base text-gray-900 sm:text-sm"
                                />
                            </div>
                            {emailError && <p className="text-red-500 text-sm mt-1 text-left">{emailError}</p>}
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
                                    "Send Reset Link"
                                )}
                            </button>
                        </div>
                        <p className="mt-10 text-center text-sm text-gray-500">
                            Back to{" "}
                            <Link
                                to="/"
                                className="font-semibold text-indigo-500 hover:text-indigo-400"
                            >
                                Login Page
                            </Link>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    );
}