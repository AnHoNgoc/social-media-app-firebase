import React, { useState } from "react";

export default function InputField({
    id,
    type = "text",
    value,
    onChange,
    placeholder,
    isPassword = false,
}) {
    const [showPassword, setShowPassword] = useState(false);

    const inputType = isPassword ? (showPassword ? "text" : "password") : type;

    return (
        <div className="mb-4">

            <div className="relative">
                <input
                    id={id}
                    type={inputType}
                    value={value}
                    onChange={onChange}
                    placeholder={placeholder}
                    className="block w-full rounded-md bg-gray-100 px-3 py-1.5 text-base text-gray-900 sm:text-sm pr-10"
                />
                {isPassword && (
                    <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute inset-y-0 right-0 px-3 flex items-center text-gray-500"
                    >
                        {showPassword ? (
                            <span role="img" aria-label="Hide">
                                🙈
                            </span>
                        ) : (
                            <span role="img" aria-label="Show">
                                👁️
                            </span>
                        )}
                    </button>
                )}
            </div>
        </div>
    );
}