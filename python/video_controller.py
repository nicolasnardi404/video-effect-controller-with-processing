import tkinter as tk
from tkinter import ttk, filedialog
from pythonosc.udp_client import SimpleUDPClient
import sys
import os


class VideoEffectsController:
    def __init__(self, parent):
        # Set style
        style = ttk.Style()
        style.configure("Title.TLabel", font=("Helvetica", 12, "bold"))
        style.configure("Section.TLabelframe", padding=10)
        style.configure("Section.TLabelframe.Label", font=("Helvetica", 10, "bold"))
        style.configure("Compact.TLabelframe", padding=5)
        style.configure("Compact.TLabelframe.Label", font=("Helvetica", 9, "bold"))

        # Create main frame with padding
        self.main_frame = ttk.Frame(parent, padding="10")
        self.main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Configure grid columns to expand properly
        self.main_frame.columnconfigure(0, weight=1)
        self.main_frame.columnconfigure(1, weight=1)

        # Initialize OSC client
        self.osc = SimpleUDPClient("127.0.0.1", 12000)

        # Create sections in a more compact layout
        self.create_source_controls()

        # Create two main columns
        left_column = ttk.Frame(self.main_frame)
        left_column.grid(row=1, column=0, sticky=(tk.N, tk.S, tk.E, tk.W), padx=5)
        left_column.columnconfigure(0, weight=1)

        right_column = ttk.Frame(self.main_frame)
        right_column.grid(row=1, column=1, sticky=(tk.N, tk.S, tk.E, tk.W), padx=5)
        right_column.columnconfigure(0, weight=1)

        # Left column contents
        self.create_effect_controls(left_column)
        self.create_motion_controls(left_column)

        # Right column contents
        self.create_color_controls(right_column)
        self.create_additional_controls(right_column)

    def create_source_controls(self):
        # Source Control Section - more compact
        source_frame = ttk.LabelFrame(
            self.main_frame, text="Source", style="Compact.TLabelframe"
        )
        source_frame.grid(
            row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 5), padx=5
        )

        # Source buttons in a more compact layout
        self.source_var = tk.BooleanVar(value=True)
        ttk.Button(source_frame, text="📹 Use Camera", command=self.on_use_camera).pack(
            side=tk.LEFT, padx=5, pady=2
        )
        ttk.Button(source_frame, text="🎬 Load Video", command=self.on_load_video).pack(
            side=tk.LEFT, padx=5, pady=2
        )

    def create_effect_controls(self, parent):
        effect_frame = ttk.LabelFrame(
            parent, text="Effect", style="Section.TLabelframe"
        )
        effect_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N), pady=5)
        effect_frame.columnconfigure(1, weight=1)

        # Effect selector
        ttk.Label(effect_frame, text="Type:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.effect_var = tk.StringVar(value="Tunnel")
        effects = ttk.Combobox(effect_frame, textvariable=self.effect_var, width=20)
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
        effects.grid(row=0, column=1, sticky=(tk.W, tk.E), padx=5)
        effects.bind("<<ComboboxSelected>>", self.on_effect_change)

        # Effect parameters
        self.create_slider(effect_frame, "Size", "size_var", 0.1, 3.0, 1.0, 1)
        self.create_slider(effect_frame, "Speed", "effect_speed_var", 0.1, 3.0, 1.0, 2)
        self.create_slider(
            effect_frame, "Polygon Sides", "polygon_sides_var", 3, 12, 4, 3
        )

    def create_color_controls(self, parent):
        color_frame = ttk.LabelFrame(parent, text="Color", style="Section.TLabelframe")
        color_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N), pady=5)
        color_frame.columnconfigure(1, weight=1)

        # Color mode selector
        ttk.Label(color_frame, text="Mode:").grid(row=0, column=0, sticky=tk.W, pady=2)
        self.color_mode_var = tk.StringVar(value="Rainbow")
        color_modes = ttk.Combobox(
            color_frame, textvariable=self.color_mode_var, width=20
        )
        color_modes["values"] = (
            "Rainbow",
            "Monochromatic",
            "Complementary",
            "Analogous",
            "Custom",
        )
        color_modes.grid(row=0, column=1, sticky=(tk.W, tk.E), padx=5)
        color_modes.bind("<<ComboboxSelected>>", self.on_color_mode_change)

        # Color parameters
        self.create_slider(color_frame, "Base Hue", "base_hue_var", 0, 360, 0, 1)
        self.create_slider(color_frame, "Brightness", "brightness_var", 0, 2, 1.0, 2)
        self.create_slider(color_frame, "Saturation", "saturation_var", 0, 2, 1.0, 3)
        self.create_slider(color_frame, "RGB Shift", "rgbshift_var", 0, 1, 0.0, 4)
        self.create_slider(color_frame, "Noise", "noise_var", 0, 1, 0.0, 5)

    def create_motion_controls(self, parent):
        motion_frame = ttk.LabelFrame(
            parent, text="Motion", style="Section.TLabelframe"
        )
        motion_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=5)
        motion_frame.columnconfigure(1, weight=1)

        self.create_slider(motion_frame, "Rotation", "rotation_var", 0, 3, 0.5, 0)
        self.create_slider(motion_frame, "Zoom", "zoom_var", -500, 500, 0, 1)

    def create_additional_controls(self, parent):
        additional_frame = ttk.LabelFrame(
            parent, text="Options", style="Section.TLabelframe"
        )
        additional_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5)
        additional_frame.columnconfigure(0, weight=1)

        # Checkboxes in a more compact 2x2 grid
        check_frame = ttk.Frame(additional_frame)
        check_frame.grid(row=0, column=0, sticky=(tk.W, tk.E), pady=2)
        check_frame.columnconfigure((0, 1), weight=1)

        self.create_checkbox(check_frame, "👻 Ghost", "ghost_var", 0, 0)
        self.create_checkbox(check_frame, "🖱️ Mouse", "mouse_control_var", 0, 1)
        self.create_checkbox(check_frame, "🎦 BG", "background_var", 1, 0)
        self.create_checkbox(check_frame, "⏺️ REC", "recording_var", 1, 1)

        # Text controls
        text_frame = ttk.Frame(additional_frame)
        text_frame.grid(row=1, column=0, sticky=(tk.W, tk.E), pady=2)
        text_frame.columnconfigure(1, weight=1)

        ttk.Label(text_frame, text="Text:").grid(row=0, column=0, sticky=tk.W, padx=2)
        self.text_var = tk.StringVar(value="")
        text_entry = ttk.Entry(text_frame, textvariable=self.text_var)
        text_entry.grid(row=0, column=1, sticky=(tk.W, tk.E), padx=2)
        text_entry.bind("<Return>", self.on_text_change)
        text_entry.bind("<KeyRelease>", self.on_text_change)

        self.text_area = tk.Text(text_frame, height=3, width=30)
        self.text_area.grid(
            row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), padx=2, pady=2
        )
        self.text_area.bind("<KeyRelease>", self.on_text_area_change)

        # Text appearance controls
        self.create_slider(text_frame, "Size", "text_size_var", 12, 72, 24, 2)

        ttk.Label(text_frame, text="Color:").grid(row=3, column=0, sticky=tk.W, padx=2)
        self.text_color_var = tk.StringVar(value="White")
        text_colors = ttk.Combobox(
            text_frame, textvariable=self.text_color_var, width=20
        )
        text_colors["values"] = ("White", "Black", "Rainbow", "Custom")
        text_colors.grid(row=3, column=1, sticky=(tk.W, tk.E), padx=2)
        text_colors.bind("<<ComboboxSelected>>", self.on_text_color_change)

        self.create_slider(text_frame, "Glitch", "text_glitch_var", 0, 1.0, 0, 4)
        self.create_slider(text_frame, "RGB Split", "text_rgb_var", 0, 1.0, 0, 5)

        # Background stage
        bg_frame = ttk.Frame(additional_frame)
        bg_frame.grid(row=2, column=0, sticky=(tk.W, tk.E), pady=2)
        bg_frame.columnconfigure(1, weight=1)

        ttk.Label(bg_frame, text="Background Stage:").grid(
            row=0, column=0, sticky=tk.W, padx=2
        )
        self.bg_stage_var = tk.StringVar(value="Normal")
        bg_stages = ttk.Combobox(bg_frame, textvariable=self.bg_stage_var, width=20)
        bg_stages["values"] = (
            "Normal",
            "B&W Dynamic",
            "Edge Detection",
            "Color Explosion",
            "Psychedelic Mirror",
        )
        bg_stages.grid(row=0, column=1, sticky=(tk.W, tk.E), padx=2)
        bg_stages.bind("<<ComboboxSelected>>", self.on_bg_stage_change)

    def create_slider(
        self, parent, label, var_name, min_val, max_val, default_val, row
    ):
        ttk.Label(parent, text=label + ":").grid(row=row, column=0, sticky=tk.W, pady=2)
        setattr(self, var_name, tk.DoubleVar(value=default_val))
        slider = ttk.Scale(
            parent,
            from_=min_val,
            to=max_val,
            variable=getattr(self, var_name),
            orient=tk.HORIZONTAL,
            command=getattr(self, f"on_{var_name.lower().replace('_var', '')}_change"),
        )
        slider.grid(row=row, column=1, sticky=(tk.W, tk.E), padx=5, pady=2)

    def create_checkbox(self, parent, text, var_name, row, col):
        setattr(self, var_name, tk.BooleanVar(value=False))
        check = ttk.Checkbutton(
            parent,
            text=text,
            variable=getattr(self, var_name),
            command=getattr(self, f"on_{var_name.lower().replace('_var', '')}_change"),
        )
        check.grid(row=row, column=col, padx=10, pady=2, sticky=tk.W)

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

    def on_bg_stage_change(self, event):
        stage_map = {
            "Normal": 0,
            "B&W Dynamic": 1,
            "Edge Detection": 2,
            "Color Explosion": 3,
            "Psychedelic Mirror": 4,
        }
        stage_value = stage_map[self.bg_stage_var.get()]
        self.osc.send_message("/background_stage", stage_value)

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

    def on_text_area_change(self, event=None):
        text = self.text_area.get("1.0", "end-1c")  # Get text without trailing newline
        self.osc.send_message("/text", text)

    def on_text_change(self, event=None):
        # Keep this for single-line entry compatibility
        self.osc.send_message("/text", self.text_var.get())

    def on_text_size_change(self, value):
        self.osc.send_message("/text_size", float(value))

    def on_text_color_change(self, event):
        color_map = {
            "White": 0,
            "Black": 1,
            "Rainbow": 2,
            "Custom": 3,
        }
        color_value = color_map[self.text_color_var.get()]
        self.osc.send_message("/text_color", color_value)

    def on_text_glitch_change(self, value):
        self.osc.send_message("/text_glitch", float(value))

    def on_text_rgb_change(self, value):
        self.osc.send_message("/text_rgb", float(value))
