# Video Effects Controller

A powerful video effects controller that allows you to create stunning visual effects with your camera or video files.

## For Users

### Windows Users
1. Download the latest release from the releases page
2. Extract the ZIP file
3. Run `VideoEffectsController.exe`
4. Make sure Processing is running with the corresponding sketch

### Mac Users
1. Download the latest release from the releases page
2. Extract the ZIP file
3. Run `VideoEffectsController.app`
4. Make sure Processing is running with the corresponding sketch

## For Developers

### Setup Development Environment

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the application:
```bash
python python/main.py
```

### Building the Executable

#### Windows
```bash
pyinstaller --name VideoEffectsController --windowed --onefile python/main.py
```

#### Mac
```bash
pyinstaller --name VideoEffectsController --windowed --onefile python/main.py
```

### Dependencies
- Python 3.8+
- python-osc
- tkinter (usually comes with Python)
- Processing 4.0+ (for the visual effects)

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