const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.deleteUser = onCall({ region: "us-central1" }, async (req) => {
    try {
        const { uid } = req.data;
        console.log("Extracted UID:", uid);

        if (!uid) {
            throw new HttpsError("invalid-argument", "Missing UID");
        }

        // Xóa user trong Firebase Auth
        await admin.auth().deleteUser(uid);
        console.log(`✅ Deleted user from Auth: ${uid}`);

        // Xóa document Firestore nếu tồn tại
        const userDocRef = admin.firestore().collection("users").doc(uid);
        const userDoc = await userDocRef.get();

        if (userDoc.exists) {
            await userDocRef.delete();
            console.log(`🗑️ Deleted user document from Firestore: ${uid}`);
        } else {
            console.log(`ℹ️ No Firestore document found for UID: ${uid}`);
        }

        return {
            success: true,
            message: "User deleted from Auth and Firestore",
        };
    } catch (error) {
        console.error("🔥 Error deleting user:", error);

        // Nếu lỗi là từ HttpsError sẵn thì ném lại
        if (error instanceof HttpsError) throw error;

        // Còn lại: gói lại thành HttpsError để client hiểu
        throw new HttpsError("internal", error.message || "Failed to delete user");
    }
});

