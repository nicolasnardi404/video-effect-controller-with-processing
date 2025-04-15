import tkinter as tk
from video_controller import VideoEffectsController


def main():
    # Create the main window
    root = tk.Tk()
    root.title("Video Effects Controller")

    # Set a minimum size for the window
    root.minsize(1000, 800)

    # Configure the window style
    root.configure(bg="#2E2E2E")

    # Create and start the controller
    app = VideoEffectsController(root)

    # Center the window on screen
    window_width = 1200
    window_height = 900
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    center_x = int(screen_width / 2 - window_width / 2)
    center_y = int(screen_height / 2 - window_height / 2)
    root.geometry(f"{window_width}x{window_height}+{center_x}+{center_y}")

    # Start the application
    root.mainloop()


if __name__ == "__main__":
    main()
