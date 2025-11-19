import { NavLink } from "react-router-dom";

const Navbar = () => {

    const navItems = [
        { name: "Dashboard", path: "/dashboard" },
        { name: "Posts", path: "/posts" },
        { name: "Users", path: "/users" }
    ];

    return (
        <nav className="bg-gray-100 dark:bg-gray-900 w-full">
            <div className="max-w-7xl mx-auto px-6 py-3">
                <ul className="flex space-x-6">
                    {navItems.map((item) => (
                        <li key={item.name}>
                            <NavLink
                                to={item.path}
                                className={({ isActive }) =>
                                    `px-3 py-2 rounded-lg font-medium ${isActive
                                        ? "text-blue-600"
                                        : "text-gray-700 dark:text-gray-300 hover:text-blue-500"
                                    }`
                                }
                            >
                                {item.name}
                            </NavLink>
                        </li>
                    ))}
                </ul>
            </div>
        </nav>
    );
};

export default Navbar;