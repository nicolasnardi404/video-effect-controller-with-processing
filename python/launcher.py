import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import sys
import os
import time
import signal
import platform
from video_controller import VideoEffectsController


class IntegratedLauncher:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Video Effects Suite")
        self.processing_process = None

        # Set up macOS application properties
        if platform.system() == "Darwin":
            # This tells macOS to use Python.app's icon and identity
            os.environ["PYTHONEXECUTABLE"] = (
                "/Applications/Python 3.12/IDLE.app/Contents/MacOS/Python"
            )
            self.root.createcommand("::tk::mac::OpenDocument", self.open_file)
            self.root.createcommand("::tk::mac::ShowPreferences", self.show_preferences)
            self.root.createcommand("::tk::mac::ReopenApplication", self.reopen)
            self.root.createcommand("::tk::mac::Quit", self.on_closing)

            # Set the process name to Python
            try:
                import Foundation
                import AppKit

                bundle = Foundation.NSBundle.mainBundle()
                info = bundle.localizedInfoDictionary() or bundle.infoDictionary()
                info["CFBundleName"] = "Python"
            except:
                pass

        # Configure main window
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

        # Create main frame
        self.main_frame = ttk.Frame(self.root, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Status frame
        self.status_frame = ttk.LabelFrame(self.main_frame, text="Status", padding="5")
        self.status_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5)

        self.status_label = ttk.Label(self.status_frame, text="Status: Not Running")
        self.status_label.grid(row=0, column=0, sticky=tk.W)

        # Control buttons
        self.button_frame = ttk.Frame(self.main_frame)
        self.button_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=5)

        self.start_button = ttk.Button(
            self.button_frame, text="Start", command=self.start_all
        )
        self.start_button.grid(row=0, column=0, padx=5)

        self.stop_button = ttk.Button(
            self.button_frame, text="Stop", command=self.stop_all, state="disabled"
        )
        self.stop_button.grid(row=0, column=1, padx=5)

        # Controller frame
        self.controller_frame = ttk.LabelFrame(
            self.main_frame, text="Effects Controller", padding="5"
        )
        self.controller_frame.grid(
            row=2, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5
        )

        # Initialize controller (but don't show it yet)
        self.controller = VideoEffectsController(self.controller_frame)
        self.controller.main_frame.grid_remove()  # Hide until started

        # Find Processing path
        self.processing_path = self.find_processing_path()
        if not self.processing_path:
            messagebox.showerror(
                "Error",
                "Processing not found. Please install Processing and try again.",
            )
            self.root.destroy()
            return

    def find_processing_path(self):
        """Find the Processing executable path based on the OS"""
        if platform.system() == "Darwin":  # macOS
            # For Processing 4, we use the Processing executable directly
            paths = [
                "/Applications/Processing.app/Contents/MacOS/Processing",
                os.path.expanduser(
                    "~/Applications/Processing.app/Contents/MacOS/Processing"
                ),
            ]
            for path in paths:
                if os.path.exists(path):
                    return path
        elif platform.system() == "Windows":
            paths = [
                "C:\\Program Files\\Processing\\processing-java.exe",
                "C:\\Program Files (x86)\\Processing\\processing-java.exe",
            ]
            for path in paths:
                if os.path.exists(path):
                    return path
        return None

    def start_processing(self):
        """Start the Processing sketch"""
        sketch_path = os.path.abspath(
            os.path.join(
                os.path.dirname(__file__), "..", "VideoEffects", "VideoEffects.pde"
            )
        )
        sketch_dir = os.path.dirname(sketch_path)

        print("Debug Info:")
        print(f"Processing Path: {self.processing_path}")
        print(f"Sketch Path: {sketch_path}")
        print(f"Sketch Dir: {sketch_dir}")
        print(f"Current Working Dir: {os.getcwd()}")
        print(f"Directory exists? {os.path.exists(sketch_dir)}")
        print(f"Sketch file exists? {os.path.exists(sketch_path)}")

        if platform.system() == "Darwin":
            # For Processing 4 on macOS, we need to use the CLI differently
            cmd = [self.processing_path, sketch_path]
        else:  # Windows
            cmd = [self.processing_path, "--force", "--sketch=" + sketch_dir, "--run"]

        print(f"Command to run: {' '.join(cmd)}")

        try:
            self.processing_process = subprocess.Popen(cmd)
            return True
        except Exception as e:
            messagebox.showerror(
                "Error", f"Failed to start Processing sketch: {str(e)}"
            )
            return False

    def start_all(self):
        """Start both Processing sketch and controller"""
        if self.start_processing():
            # Wait a bit for Processing to initialize
            time.sleep(2)

            # Show controller
            self.controller.main_frame.grid()

            # Update UI
            self.start_button.config(state="disabled")
            self.stop_button.config(state="normal")
            self.status_label.config(text="Status: Running")

    def stop_all(self):
        """Stop both Processing sketch and controller"""
        if self.processing_process:
            if platform.system() == "Windows":
                self.processing_process.terminate()
            else:
                os.kill(self.processing_process.pid, signal.SIGTERM)
            self.processing_process = None

        # Hide controller
        self.controller.main_frame.grid_remove()

        # Update UI
        self.start_button.config(state="normal")
        self.stop_button.config(state="disabled")
        self.status_label.config(text="Status: Not Running")

    def on_closing(self):
        """Handle window closing"""
        self.stop_all()
        self.root.destroy()

    def open_file(self, *args):
        pass

    def show_preferences(self):
        pass

    def reopen(self):
        self.root.deiconify()

    def run(self):
        """Start the application"""
        self.root.mainloop()


if __name__ == "__main__":
    app = IntegratedLauncher()
    app.run()
