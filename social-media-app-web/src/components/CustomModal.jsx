import { createPortal } from "react-dom";

export default function CustomModal({
    open = false,
    title = "Modal Title",
    children,
    confirmText = "Confirm",
    cancelText = "Cancel",
    onConfirm,
    onClose,
}) {
    if (!open) return null;

    return createPortal(
        <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
            onClick={onClose}
        >
            <div
                className="bg-white dark:bg-gray-800 rounded-lg shadow-lg w-96 max-w-full p-6 relative"
                style={{ border: "1px solid #ccc" }}
                onClick={(e) => e.stopPropagation()}
            >
                <h2 className="text-lg font-semibold mb-4 text-gray-800 dark:text-white">{title}</h2>
                <div className="mb-6 text-gray-700 dark:text-gray-200">{children}</div>
                <div className="flex justify-end space-x-3">
                    <button
                        className="px-4 py-2 rounded-md bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-800 dark:text-gray-100"
                        onClick={onClose}
                    >
                        {cancelText}
                    </button>
                    <button
                        className="px-4 py-2 rounded-md bg-green-500 text-white hover:bg-green-600"
                        onClick={() => {
                            onConfirm && onConfirm();
                            onClose && onClose();
                        }}
                    >
                        {confirmText}
                    </button>
                </div>
            </div>
        </div>,
        document.body
    );
}