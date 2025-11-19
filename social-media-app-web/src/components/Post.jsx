import moment from "moment";
import { AiFillHeart, AiOutlineUser } from "react-icons/ai";
import { FiMoreHorizontal } from "react-icons/fi";
import { useState, useEffect } from "react";
import { getProfileImageByUid } from "../services/userService";
import { deletePost } from "../services/postService";
import CustomModal from "./CustomModal";
import toast from "react-hot-toast";

export default function Post({ post, onPostDeleted }) {
    const [showAllComments, setShowAllComments] = useState(false);
    const [imageLoaded, setImageLoaded] = useState(false);
    const [profileImage, setProfileImage] = useState(null);
    const [showMenu, setShowMenu] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);

    const toggleComments = () => setShowAllComments(!showAllComments);
    const toggleMenu = () => setShowMenu(!showMenu);

    useEffect(() => {
        const fetchProfileImage = async () => {
            const url = await getProfileImageByUid(post.userId);
            setProfileImage(url);
        };
        fetchProfileImage();
    }, [post.userId]);

    const handleDelete = async () => {
        try {
            await deletePost(post.id);
            onPostDeleted && onPostDeleted(post.id); // callback update UI
            toast.success("Post deleted successfully!"); // toast thông báo
        } catch (error) {
            console.error("Failed to delete post:", error);
            toast.error("Failed to delete post.");
        }
    };

    return (
        <div className="bg-white dark:bg-gray-700 rounded-lg shadow p-4 mb-4">
            {/* User info */}
            <div className="flex items-start mb-2">
                {/* Profile image */}
                <div className="mr-3 w-12 h-12 flex items-center justify-center rounded-full bg-gray-300 overflow-hidden">
                    {profileImage ? (
                        <img
                            src={profileImage}
                            alt="Profile"
                            className="w-full h-full object-cover"
                        />
                    ) : (
                        <AiOutlineUser className="text-white w-6 h-6" />
                    )}
                </div>

                {/* Username + time */}
                <div className="flex-1">
                    <div className="font-semibold text-gray-800 dark:text-white">
                        {post.userName}
                    </div>
                    <div className="text-gray-500 text-sm">
                        {moment(post.timestamp.toDate()).fromNow()}
                    </div>
                </div>

                {/* 3 chấm menu */}
                <div className="relative">
                    <button
                        onClick={toggleMenu}
                        className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                    >
                        <FiMoreHorizontal size={20} />
                    </button>

                    {showMenu && (
                        <div className="absolute right-0 mt-2 w-32 bg-white dark:bg-gray-600 border border-gray-200 dark:border-gray-500 rounded shadow-md z-10">
                            <button
                                onClick={() => {
                                    setShowDeleteModal(true);
                                    setShowMenu(false);
                                }}
                                className="w-full text-left px-4 py-2 text-red-600 hover:bg-gray-100 dark:hover:bg-gray-500 rounded"
                            >
                                Delete Post
                            </button>
                        </div>
                    )}
                </div>
            </div>

            {/* Post text */}
            {post.text && (
                <p className="text-gray-800 dark:text-gray-200 text-lg my-3">
                    {post.text}
                </p>
            )}

            {/* Post image */}
            {post.imageUrl && (
                <div className="relative w-full mb-2">
                    <img
                        src={post.imageUrl}
                        alt="Post"
                        className={`w-full h-auto object-contain transition-opacity duration-500 ${imageLoaded ? "opacity-100" : "opacity-0"}`}
                        onLoad={() => setImageLoaded(true)}
                    />
                    {!imageLoaded && (
                        <div className="absolute inset-0 flex items-center justify-center bg-gray-200 dark:bg-gray-600">
                            <svg
                                className="animate-spin h-8 w-8 text-gray-500"
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
                                    d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                                ></path>
                            </svg>
                        </div>
                    )}
                </div>
            )}

            {/* Likes */}
            <div className="flex items-center text-gray-500 text-lg mb-2">
                <AiFillHeart className="text-red-500 mr-2 text-2xl" />
                <span className="text-lg font-semibold">{post.likes?.length || 0}</span>
            </div>

            {/* Comments */}
            {post.comments && post.comments.length > 0 && (
                <div className="mt-2">
                    <div className="font-semibold text-gray-700 dark:text-gray-300 mb-1">
                        Comments:
                    </div>

                    <div className="space-y-1">
                        {post.comments
                            .slice(0, showAllComments ? post.comments.length : 2)
                            .map((c) => (
                                <div
                                    key={c.id}
                                    className="bg-gray-100 dark:bg-gray-600 rounded p-2 text-sm"
                                >
                                    <span className="font-semibold">{c.userName}: </span>
                                    {c.text}
                                    <div className="text-gray-400 text-xs">
                                        {moment(c.timestamp.toDate()).fromNow()}
                                    </div>
                                </div>
                            ))}

                        {post.comments.length > 2 && (
                            <button
                                onClick={() => setShowAllComments(!showAllComments)}
                                className="text-blue-500 text-sm mt-1 hover:underline"
                            >
                                {showAllComments ? "View less" : "View more..."}
                            </button>
                        )}
                    </div>
                </div>
            )}

            {/* Modal xác nhận xóa */}
            <CustomModal
                open={showDeleteModal}
                title="Confirm Delete"
                confirmText="Delete"
                cancelText="Cancel"
                onClose={() => setShowDeleteModal(false)}
                onConfirm={handleDelete}
            >
                Are you sure you want to delete this post?
            </CustomModal>
        </div>
    );
}