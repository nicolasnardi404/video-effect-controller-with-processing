# Video Effects Controller

A powerful video effects controller that allows you to create stunning visual effects with your camera or video files. Built with Processing and Python, this project combines real-time video processing with an intuitive control interface.

## Development Setup

### Prerequisites
- Python 3.8+
- Processing 4.0+
- python-osc
- tkinter (usually comes with Python)

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Open Processing and install the following libraries:
   - Video Library
   - Video Export
   - OscP5
   - NetP5

4. Run the application:
   - First, open and run `VideoEffects/VideoEffects.pde` in Processing
   - Then run the Python controller:
   ```bash
   python python/main.py
   ```

## Project Structure

- `/python/` - Python controller code
  - `main.py` - Main application launcher
  - `video_controller.py` - GUI control interface with tkinter

- `/VideoEffects/` - Processing sketches
  - `VideoEffects.pde` - Main Processing sketch
  - `shaders/` - GLSL shader files for effects

## Features

### Visual Effects
- Tunnel Effect
- Spherical Effect
- Particle Effect
- Vortex Effect
- Cube Effect
- Kaleidoscope Effect
- Wave Grid Effect
- Spiral Tower Effect
- Polygon Effect

### Real-time Controls
- Effect Parameters:
  - Selection
  - Speed
  - Size
  - Polygon sides
  
- Color Controls:
  - Multiple modes (Rainbow, Monochromatic, Complementary, Analogous, Custom)
  - Base hue adjustment
  - Brightness
  - Saturation
  - RGB Shift
  - Noise effects

- Motion Controls:
  - Rotation speed
  - Zoom level
  - Mouse interaction

- Text Overlay:
  - Multi-line text support
  - Dynamic text effects
  - RGB split
  - Glitch effects
  - Multiple color modes

- Background Options:
  - Video/Camera toggle
  - Multiple background stages
  - Ghost effect
  - Recording capability

## Communication

The project uses OSC (Open Sound Control) for communication between Python and Processing:
- Python controller sends messages on port 12000
- Processing sketch listens for OSC messages and updates accordingly

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Processing Foundation for the Processing development environment
- Python-OSC for communication between Python and Processing
- Tkinter for the GUI framework 