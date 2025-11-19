import React, { useEffect, useState } from "react";
import { getPosts } from "../services/postService";
import Post from "../components/Post";

export default function Posts() {
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPosts = async () => {
            try {
                const data = await getPosts(); // getPosts đã sắp xếp timestamp desc
                setPosts(data);
            } catch (error) {
                console.error("Error fetching posts:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchPosts();
    }, []);


    const handlePostDeleted = (deletedPostId) => {
        // Cập nhật state loại bỏ post vừa xóa
        setPosts((prevPosts) => prevPosts.filter((p) => p.id !== deletedPostId));
    };

    if (loading) {
        return <div className="p-4 text-center text-gray-700">Loading posts...</div>;
    }

    if (!posts.length) {
        return <div className="p-4 text-center text-gray-700">No posts found.</div>;
    }

    return (
        <div className="max-w-3xl mx-auto p-4">
            {posts.map((post) => (
                <Post key={post.id} post={post} onPostDeleted={handlePostDeleted} />
            ))}
        </div>
    );
}