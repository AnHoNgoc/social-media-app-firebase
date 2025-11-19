import { auth, db } from "../firebase";
import {
    signInWithEmailAndPassword, signOut, createUserWithEmailAndPassword,
    sendPasswordResetEmail, updatePassword, reauthenticateWithCredential, EmailAuthProvider
} from "firebase/auth";
import { doc, getDoc, setDoc, serverTimestamp } from "firebase/firestore";

// Login
export const loginAdmin = async (email, password) => {
    // Đăng nhập vào Firebase Auth
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    // Lấy role trong Firestore
    const docRef = doc(db, "users", user.uid);
    const docSnap = await getDoc(docRef);

    if (!docSnap.exists()) {
        throw new Error("User data not found in Firestore.");
    }

    const userData = docSnap.data();

    // Kiểm tra role
    if (userData.role !== "admin") {
        // Nếu không phải admin thì đăng xuất luôn
        await signOut(auth);
        throw new Error("Access denied. You are not an admin.");
    }

    return user; // ✅ Đăng nhập hợp lệ (admin)
};

// Logout
export const logoutAdmin = async () => {
    return await signOut(auth);
};

// Register
export const registerAdmin = async (email, password) => {

    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    // 2️⃣ Tạo document trong Firestore (collection: "users")
    await setDoc(doc(db, "users", user.uid), {
        email: user.email,
        role: "customer",
        createdAt: serverTimestamp(),
    });

    // 3️⃣ Trả user về nếu cần
    return user;
};


export const sendPasswordReset = async (email) => {
    try {
        await sendPasswordResetEmail(auth, email);
        return "Password reset email sent successfully.";
    } catch (error) {
        console.error("Error sending password reset email:", error);
        throw error;
    }
};


export const changePassword = async (currentPassword, newPassword) => {
    const user = auth.currentUser;

    if (!user) {
        throw new Error("No user is currently logged in.");
    }

    // ✅ Kiểm tra xem mật khẩu mới có khác mật khẩu cũ không
    if (currentPassword === newPassword) {
        throw new Error("New password must be different from the current password.");
    }

    try {
        // 1️⃣ Xác thực lại người dùng
        const credential = EmailAuthProvider.credential(user.email, currentPassword);
        await reauthenticateWithCredential(user, credential);

        // 2️⃣ Đổi mật khẩu
        await updatePassword(user, newPassword);

        return "Password updated successfully.";
    } catch (error) {
        console.error("Error changing password:", error);
        throw error;
    }
};