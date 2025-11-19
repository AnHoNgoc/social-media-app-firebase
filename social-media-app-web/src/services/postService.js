import { db } from "../firebase";
import { collection, getDocs, getDoc, addDoc, updateDoc, doc, deleteDoc, getCountFromServer, query, orderBy, where } from "firebase/firestore";
import moment from "moment";
// Collection "posts"
const postsCollection = collection(db, "posts");

// Lấy tất cả posts
export const getPosts = async () => {
    try {
        // Query sắp xếp theo timestamp giảm dần (mới nhất trước)
        const q = query(postsCollection, orderBy("timestamp", "desc"));
        const snapshot = await getDocs(q);
        return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
        console.error("Error getting posts:", error);
        return [];
    }
};

// Lấy chi tiết post theo id
export const getPostDetail = async (id) => {
    try {
        const postDoc = doc(postsCollection, id);
        const snapshot = await getDoc(postDoc);
        if (snapshot.exists()) {
            return snapshot.data();
        } else {
            console.warn("No post found with id:", id);
            return null;
        }
    } catch (error) {
        console.error("Error getting post detail:", error);
        return null;
    }
};

// Thêm post mới
export const addPost = async (data) => {
    try {
        const docRef = await addDoc(postsCollection, data);
        return docRef.id;
    } catch (error) {
        console.error("Error adding post:", error);
        return null;
    }
};

// Cập nhật post theo id
export const updatePost = async (id, data) => {
    try {
        const postDoc = doc(postsCollection, id);
        await updateDoc(postDoc, data);
    } catch (error) {
        console.error("Error updating post:", error);
        throw error; // để handle ở hàm gọi
    }
};

// Xóa post theo id
export const deletePost = async (id) => {
    try {
        const postDoc = doc(postsCollection, id);
        await deleteDoc(postDoc);
    } catch (error) {
        console.error("Error deleting post:", error);
        throw error; // để handle ở hàm gọi
    }
};

// Đếm số lượng post
export const countPosts = async () => {
    try {
        const snapshot = await getCountFromServer(postsCollection);
        return snapshot.data().count;
    } catch (error) {
        console.error("Error counting posts:", error);
        return 0;
    }
};

export const countPostsLast3Months = async () => {
    try {
        const now = moment();
        const threeMonthsAgo = now.clone().subtract(2, "months").startOf("month");
        // startOf("month") để lấy tháng đầu tiên trong 3 tháng

        // Lấy tất cả post từ 3 tháng trước tới giờ
        const q = query(postsCollection, where("timestamp", ">=", threeMonthsAgo.toDate()));
        const snapshot = await getDocs(q);

        const counts = {};

        snapshot.forEach(doc => {
            const data = doc.data();
            const ts = data.timestamp?.toDate();
            if (!ts) return;

            const monthKey = moment(ts).format("MMM YYYY"); // ví dụ "Nov 2025"
            counts[monthKey] = (counts[monthKey] || 0) + 1;
        });

        // Tạo mảng 3 tháng gần nhất
        const chartData = [];
        for (let i = 2; i >= 0; i--) {
            const m = now.clone().subtract(i, "months");
            const key = m.format("MMM YYYY");
            chartData.push({ month: key, count: counts[key] || 0 });
        }

        return chartData;
    } catch (error) {
        console.error("Error counting posts last 3 months:", error);
        return [];
    }
};