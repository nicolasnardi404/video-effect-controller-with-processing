import tkinter as tk
from tkinter import ttk, filedialog
from pythonosc.udp_client import SimpleUDPClient
import sys
import os


class VideoEffectsController:
    def __init__(self, parent):
        # Create main frame
        self.main_frame = ttk.Frame(parent, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Initialize OSC client
        self.osc = SimpleUDPClient("127.0.0.1", 12000)

        # Effect selector
        ttk.Label(self.main_frame, text="Effect:").grid(row=0, column=0, sticky=tk.W)
        self.effect_var = tk.StringVar(value="Tunnel")
        effects = ttk.Combobox(self.main_frame, textvariable=self.effect_var)
        effects["values"] = (
            "Tunnel",
            "Spherical",
            "Particle",
            "Vortex",
            "Cube",
            "Kaleidoscope",
            "Wave Grid",
            "Spiral Tower",
            "Polygon",
        )
        effects.grid(row=0, column=1, sticky=(tk.W, tk.E))
        effects.bind("<<ComboboxSelected>>", self.on_effect_change)

        # Color Mode selector
        ttk.Label(self.main_frame, text="Color Mode:").grid(
            row=1, column=0, sticky=tk.W
        )
        self.color_mode_var = tk.StringVar(value="Rainbow")
        color_modes = ttk.Combobox(self.main_frame, textvariable=self.color_mode_var)
        color_modes["values"] = (
            "Rainbow",
            "Monochromatic",
            "Complementary",
            "Analogous",
            "Custom",
        )
        color_modes.grid(row=1, column=1, sticky=(tk.W, tk.E))
        color_modes.bind("<<ComboboxSelected>>", self.on_color_mode_change)

        # Base Hue
        ttk.Label(self.main_frame, text="Base Hue:").grid(row=2, column=0, sticky=tk.W)
        self.base_hue_var = tk.DoubleVar(value=0)
        base_hue_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=360,
            variable=self.base_hue_var,
            orient=tk.HORIZONTAL,
            command=self.on_base_hue_change,
        )
        base_hue_scale.grid(row=2, column=1, sticky=(tk.W, tk.E))

        # Rotation speed
        ttk.Label(self.main_frame, text="Rotation:").grid(row=3, column=0, sticky=tk.W)
        self.rotation_var = tk.DoubleVar(value=0.5)
        rotation_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=3,
            variable=self.rotation_var,
            orient=tk.HORIZONTAL,
            command=self.on_rotation_change,
        )
        rotation_scale.grid(row=3, column=1, sticky=(tk.W, tk.E))

        # Effect Speed
        ttk.Label(self.main_frame, text="Effect Speed:").grid(
            row=4, column=0, sticky=tk.W
        )
        self.effect_speed_var = tk.DoubleVar(value=1.0)
        effect_speed_scale = ttk.Scale(
            self.main_frame,
            from_=0.1,
            to=3.0,
            variable=self.effect_speed_var,
            orient=tk.HORIZONTAL,
            command=self.on_effect_speed_change,
        )
        effect_speed_scale.grid(row=4, column=1, sticky=(tk.W, tk.E))

        # Zoom
        ttk.Label(self.main_frame, text="Zoom:").grid(row=5, column=0, sticky=tk.W)
        self.zoom_var = tk.DoubleVar(value=0)
        zoom_scale = ttk.Scale(
            self.main_frame,
            from_=-500,
            to=500,
            variable=self.zoom_var,
            orient=tk.HORIZONTAL,
            command=self.on_zoom_change,
        )
        zoom_scale.grid(row=5, column=1, sticky=(tk.W, tk.E))

        # Size Multiplier
        ttk.Label(self.main_frame, text="Size:").grid(row=6, column=0, sticky=tk.W)
        self.size_var = tk.DoubleVar(value=1.0)
        size_scale = ttk.Scale(
            self.main_frame,
            from_=0.1,
            to=3.0,
            variable=self.size_var,
            orient=tk.HORIZONTAL,
            command=self.on_size_change,
        )
        size_scale.grid(row=6, column=1, sticky=(tk.W, tk.E))

        # Brightness
        ttk.Label(self.main_frame, text="Brightness:").grid(
            row=7, column=0, sticky=tk.W
        )
        self.brightness_var = tk.DoubleVar(value=1.0)
        brightness_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=2,
            variable=self.brightness_var,
            orient=tk.HORIZONTAL,
            command=self.on_brightness_change,
        )
        brightness_scale.grid(row=7, column=1, sticky=(tk.W, tk.E))

        # Saturation
        ttk.Label(self.main_frame, text="Saturation:").grid(
            row=8, column=0, sticky=tk.W
        )
        self.saturation_var = tk.DoubleVar(value=1.0)
        saturation_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=2,
            variable=self.saturation_var,
            orient=tk.HORIZONTAL,
            command=self.on_saturation_change,
        )
        saturation_scale.grid(row=8, column=1, sticky=(tk.W, tk.E))

        # RGB Shift
        ttk.Label(self.main_frame, text="RGB Shift:").grid(row=9, column=0, sticky=tk.W)
        self.rgbshift_var = tk.DoubleVar(value=0.0)
        rgbshift_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=1,
            variable=self.rgbshift_var,
            orient=tk.HORIZONTAL,
            command=self.on_rgbshift_change,
        )
        rgbshift_scale.grid(row=9, column=1, sticky=(tk.W, tk.E))

        # Noise Amount
        ttk.Label(self.main_frame, text="Noise:").grid(row=10, column=0, sticky=tk.W)
        self.noise_var = tk.DoubleVar(value=0.0)
        noise_scale = ttk.Scale(
            self.main_frame,
            from_=0,
            to=1,
            variable=self.noise_var,
            orient=tk.HORIZONTAL,
            command=self.on_noise_change,
        )
        noise_scale.grid(row=10, column=1, sticky=(tk.W, tk.E))

        # Polygon Sides
        ttk.Label(self.main_frame, text="Polygon Sides:").grid(
            row=11, column=0, sticky=tk.W
        )
        self.polygon_sides_var = tk.IntVar(value=4)
        polygon_sides_scale = ttk.Scale(
            self.main_frame,
            from_=3,
            to=12,
            variable=self.polygon_sides_var,
            orient=tk.HORIZONTAL,
            command=self.on_polygon_sides_change,
        )
        polygon_sides_scale.grid(row=11, column=1, sticky=(tk.W, tk.E))

        # Checkboxes frame
        checkbox_frame = ttk.Frame(self.main_frame)
        checkbox_frame.grid(
            row=12, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=10
        )

        # Ghost Effect
        self.ghost_var = tk.BooleanVar(value=False)
        ghost_check = ttk.Checkbutton(
            checkbox_frame,
            text="Ghost Effect",
            variable=self.ghost_var,
            command=self.on_ghost_change,
        )
        ghost_check.grid(row=0, column=0, padx=5)

        # Mouse Control
        self.mouse_control_var = tk.BooleanVar(value=True)
        mouse_control_check = ttk.Checkbutton(
            checkbox_frame,
            text="Mouse Control",
            variable=self.mouse_control_var,
            command=self.on_mouse_control_change,
        )
        mouse_control_check.grid(row=0, column=1, padx=5)

        # Show Background
        self.background_var = tk.BooleanVar(value=True)
        background_check = ttk.Checkbutton(
            checkbox_frame,
            text="Show Background",
            variable=self.background_var,
            command=self.on_background_change,
        )
        background_check.grid(row=0, column=2, padx=5)

        # Recording
        self.recording_var = tk.BooleanVar(value=False)
        recording_check = ttk.Checkbutton(
            checkbox_frame,
            text="Recording",
            variable=self.recording_var,
            command=self.on_recording_change,
        )
        recording_check.grid(row=0, column=3, padx=5)

        # Source buttons frame
        source_frame = ttk.Frame(self.main_frame)
        source_frame.grid(row=13, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=10)

        # Video/Camera source buttons
        self.source_var = tk.BooleanVar(value=True)  # True for camera, False for video
        ttk.Button(source_frame, text="Load Video", command=self.on_load_video).grid(
            row=0, column=0, padx=5
        )
        ttk.Button(source_frame, text="Use Camera", command=self.on_use_camera).grid(
            row=0, column=1, padx=5
        )

        # Configure grid
        for child in self.main_frame.winfo_children():
            child.grid_configure(padx=5, pady=5)

    def on_effect_change(self, event):
        effect_map = {
            "Tunnel": 0,
            "Spherical": 1,
            "Particle": 2,
            "Vortex": 3,
            "Cube": 4,
            "Kaleidoscope": 5,
            "Wave Grid": 6,
            "Spiral Tower": 7,
            "Polygon": 8,
        }
        effect_value = effect_map[self.effect_var.get()]
        self.osc.send_message("/effect", effect_value)

    def on_color_mode_change(self, event):
        mode_map = {
            "Rainbow": 0,
            "Monochromatic": 1,
            "Complementary": 2,
            "Analogous": 3,
            "Custom": 4,
        }
        mode_value = mode_map[self.color_mode_var.get()]
        self.osc.send_message("/colormode", mode_value)

    def on_base_hue_change(self, value):
        self.osc.send_message("/base_hue", float(value))

    def on_rotation_change(self, value):
        self.osc.send_message("/rotation", float(value))

    def on_effect_speed_change(self, value):
        self.osc.send_message("/effect_speed", float(value))

    def on_zoom_change(self, value):
        self.osc.send_message("/zoom", float(value))

    def on_size_change(self, value):
        self.osc.send_message("/size", float(value))

    def on_brightness_change(self, value):
        self.osc.send_message("/brightness", float(value))

    def on_saturation_change(self, value):
        self.osc.send_message("/saturation", float(value))

    def on_rgbshift_change(self, value):
        self.osc.send_message("/rgbshift", float(value))

    def on_noise_change(self, value):
        self.osc.send_message("/noise", float(value))

    def on_polygon_sides_change(self, value):
        self.osc.send_message("/polygon_sides", int(float(value)))

    def on_ghost_change(self):
        self.osc.send_message("/ghost", int(self.ghost_var.get()))

    def on_mouse_control_change(self):
        self.osc.send_message("/mouse_control", int(self.mouse_control_var.get()))

    def on_background_change(self):
        self.osc.send_message("/background", int(self.background_var.get()))

    def on_recording_change(self):
        self.osc.send_message("/recording", int(self.recording_var.get()))

    def on_load_video(self):
        file_path = filedialog.askopenfilename(
            filetypes=[("Video files", "*.mp4 *.avi *.mov *.mkv")]
        )
        if file_path:
            self.source_var.set(False)
            self.osc.send_message("/source", 1)  # 1 for video
            self.osc.send_message("/video_path", file_path)

    def on_use_camera(self):
        self.source_var.set(True)
        self.osc.send_message("/source", 0)  # 0 for camera
