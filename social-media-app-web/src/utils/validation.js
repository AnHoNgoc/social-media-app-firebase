export const validateEmail = (email) => {
    if (!email || email.trim() === "") {
        return "Email is required.";
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return "Invalid email address.";
    }

    return ""; // hợp lệ -> không có lỗi
};

export const validatePassword = (password) => {
    if (!password || password.trim() === "") {
        return "Password is required.";
    }

    if (password.length < 6) {
        return "Password must be at least 6 characters.";
    }

    return ""; // hợp lệ
};

export const validateConfirmPassword = (password, confirmPassword) => {
    if (!confirmPassword || confirmPassword.trim() === "") {
        return "Please confirm your password.";
    }

    if (password !== confirmPassword) {
        return "Passwords do not match!";
    }

    return "";
};


export const validateNewPassword = (oldPassword, newPassword) => {
    if (!newPassword || newPassword.trim() === "") {
        return "New password is required.";
    }

    if (newPassword.length < 6) {
        return "New password must be at least 6 characters.";
    }


    if (oldPassword && oldPassword === newPassword) {
        return "New password must be different from the current password.";
    }

    return "";
};