import { Outlet } from "react-router-dom";
import Header from "./Header";
import Navbar from "./Navbar";

const Layout = () => {
    return (
        <div className="min-h-screen flex flex-col">
            <Header />
            <Navbar />
            <main className="flex-1 p-4">
                <Outlet />
            </main>
        </div>
    );
};

export default Layout;