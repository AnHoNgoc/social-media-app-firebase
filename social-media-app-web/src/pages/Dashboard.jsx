import { useEffect, useState } from "react";
import { countPostsLast3Months, countPosts } from "../services/postService";
import { countUsers } from "../services/userService";
import {
    ResponsiveContainer,
    BarChart,
    XAxis,
    YAxis,
    Tooltip,
    Legend,
    Bar,
} from "recharts";

export default function Dashboard() {
    const [totalPosts, setTotalPosts] = useState(0);
    const [totalUsers, setTotalUsers] = useState(0);
    const [chartData, setChartData] = useState([]);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [postsCount, usersCount, posts3Months] = await Promise.all([
                    countPosts(),
                    countUsers(),
                    countPostsLast3Months(),
                ]);

                setTotalPosts(postsCount);
                setTotalUsers(usersCount);
                setChartData(posts3Months);
            } catch (error) {
                console.error("Error fetching dashboard stats:", error);
            }
        };

        fetchStats();
    }, []);

    return (
        <div className="flex flex-col min-h-screen dark:bg-gray-800">
            <div className="max-w-7xl mx-auto w-full p-6">
                <h1 className="text-2xl font-bold mb-6 text-gray-800 dark:text-white">
                    Dashboard Overview
                </h1>

                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                    <div className="p-4 bg-white dark:bg-gray-700 rounded-lg shadow">
                        Total Posts: {totalPosts}
                    </div>
                    <div className="p-4 bg-white dark:bg-gray-700 rounded-lg shadow">
                        Total Users: {totalUsers}
                    </div>
                </div>

                {/* Chart */}
                <div className="p-4 bg-white dark:bg-gray-700 rounded-lg shadow">
                    <h2 className="text-lg font-semibold mb-4 text-gray-800 dark:text-white">
                        Posts in Last 3 Months
                    </h2>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={chartData}>
                            <XAxis dataKey="month" />
                            <YAxis allowDecimals={false} />
                            <Tooltip />
                            <Legend />
                            <Bar dataKey="count" fill="#4F46E5" name="Posts" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
}
