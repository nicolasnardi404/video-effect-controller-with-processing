# Processing Video Effects Suite

A powerful video effects application that combines Processing for visual effects with a Python-based control interface. This tool allows you to apply real-time visual effects to video files or camera input.

## Features

- Multiple visual effects:
  - Tunnel Effect
  - Spherical Effect
  - Particle Effect
  - Vortex Effect
  - Cube Effect
  - Kaleidoscope Effect
  - Wave Grid Effect
  - Spiral Tower Effect
  - Polygon Effect

- Real-time controls for:
  - Effect selection
  - Color modes (Rainbow, Monochromatic, Complementary, Analogous, Custom)
  - Base hue
  - Rotation speed
  - Effect speed
  - Zoom level
  - Size multiplier
  - Brightness
  - Saturation
  - RGB Shift
  - Noise amount
  - Polygon sides

## Prerequisites

- Processing 4.x
- Python 3.12+
- Tkinter (usually comes with Python)
- Required Python packages (see `python/requirements.txt`)

## Installation

1. Clone this repository:
```bash
git clone [your-repo-url]
cd processing-video-maker
```

2. Create and activate a Python virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

3. Install Python dependencies:
```bash
pip install -r python/requirements.txt
```

4. Make sure Processing is installed on your system
   - On macOS: Install Processing.app in the Applications folder
   - On Windows: Install Processing in the default location

## Usage

1. Run the launcher:
```bash
python python/launcher.py
```

2. Click "Start" in the control panel to begin
3. Use the various sliders and controls to adjust the visual effects
4. Click "Stop" when finished

## Project Structure

- `/python/` - Python controller code
  - `launcher.py` - Main application launcher
  - `video_controller.py` - GUI control interface
  - `python_osc.py` - OSC communication handler

- `/VideoEffects/` - Processing sketches
  - `VideoEffects.pde` - Main Processing sketch
  - `Effects.pde` - Visual effects implementations
  - `Controls.pde` - Processing-side control handlers

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Processing Foundation for the Processing development environment
- Python-OSC for communication between Python and Processing
- Tkinter for the GUI framework 