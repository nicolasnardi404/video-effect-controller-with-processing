<div align="center">
  <h1>🎥 Video Effects Controller</h1>
  
  <p>
    <img src="https://img.shields.io/badge/Processing-4.0-blue?style=for-the-badge&logo=processing" alt="Processing">
    <img src="https://img.shields.io/badge/Python-3.8+-yellow?style=for-the-badge&logo=python" alt="Python">
    <img src="https://img.shields.io/badge/OSC-Protocol-green?style=for-the-badge" alt="OSC">
  </p>
  
  <p>A powerful real-time video effects controller combining Processing for visual effects with a Python-based control interface.</p>
</div>

---

## ✨ Features

<div align="center">
  <table>
    <tr>
      <td align="center">🎨</td>
      <td><strong>Visual Effects</strong><br/>9 stunning real-time effects</td>
      <td align="center">🎮</td>
      <td><strong>Live Controls</strong><br/>Dynamic parameter adjustment</td>
    </tr>
    <tr>
      <td align="center">📹</td>
      <td><strong>Dual Input</strong><br/>Camera and video file support</td>
      <td align="center">✨</td>
      <td><strong>Color Modes</strong><br/>Multiple color schemes</td>
    </tr>
    <tr>
      <td align="center">📝</td>
      <td><strong>Text Overlay</strong><br/>Dynamic text with effects</td>
      <td align="center">⚡</td>
      <td><strong>Real-time Processing</strong><br/>Instant visual feedback</td>
    </tr>
  </table>
</div>

---

## 🎨 Effect Types

<div align="center">
  <table>
    <tr>
      <td align="center">🌀</td>
      <td>Tunnel</td>
      <td align="center">🔮</td>
      <td>Spherical</td>
    </tr>
    <tr>
      <td align="center">✨</td>
      <td>Particle</td>
      <td align="center">🌪️</td>
      <td>Vortex</td>
    </tr>
    <tr>
      <td align="center">📦</td>
      <td>Cube</td>
      <td align="center">🎡</td>
      <td>Kaleidoscope</td>
    </tr>
    <tr>
      <td align="center">🌊</td>
      <td>Wave Grid</td>
      <td align="center">🗼</td>
      <td>Spiral Tower</td>
    </tr>
    <tr>
      <td align="center">⭐</td>
      <td>Polygon</td>
    </tr>
  </table>
</div>

---

## 🛠️ Technical Stack

<div align="center">
  <table>
    <tr>
      <td align="center">🎨</td>
      <td><strong>Visual Engine</strong><br/>Processing 4.0+</td>
      <td align="center">🐍</td>
      <td><strong>Controller</strong><br/>Python with Tkinter</td>
    </tr>
    <tr>
      <td align="center">📡</td>
      <td><strong>Communication</strong><br/>OSC Protocol</td>
      <td align="center">🎬</td>
      <td><strong>Video Processing</strong><br/>Processing Video Library</td>
    </tr>
  </table>
</div>

---

## 🚀 Quick Start

### Prerequisites

<div align="center">
  <table>
    <tr>
      <td align="center">🎨</td>
      <td>
        <strong>Processing 4.0+</strong><br/>
        <a href="https://processing.org/download">Download Processing</a><br/>
        The visual programming environment for creating graphics
      </td>
      <td align="center">🐍</td>
      <td>
        <strong>Python 3.8+</strong><br/>
        <a href="https://www.python.org/downloads/">Download Python</a><br/>
        Required for running the control interface
      </td>
    </tr>
  </table>
</div>

### Installation Steps

1. **Install Processing Libraries**
   - Open Processing
   - Go to `Sketch > Import Library > Add Library`
   - Search and install:
     - `Video Library` for camera and video handling
     - `Video Export` for recording capabilities
     - `OscP5` for communication with Python
     - `NetP5` (installed automatically with OscP5)

2. **Install Python Dependencies**
   ```bash
   # If you don't have pip installed
   python -m ensurepip --upgrade

   # Install required packages
   pip install -r requirements.txt
   ```

3. **Launch Application**
   ```bash
   # Simply run the launcher:
   python python/launcher.py
   ```

   The launcher will automatically:
   - Find your Processing installation
   - Start the Processing sketch
   - Launch the control interface
   - Provide status monitoring
   - Handle proper shutdown

### Troubleshooting

- **Processing Not Found**: Make sure Processing is installed in the default location
- **Python Error**: Ensure you're using Python 3.8 or newer (`python --version`)
- **Missing Libraries**: Double-check all Processing libraries are installed
- **OSC Error**: Check if port 12000 is available on your system

---

## 📁 Project Structure

<div align="center">
  <table>
    <tr>
      <td align="center">🎨</td>
      <td><strong>/VideoEffects/</strong><br/>Processing sketches & shaders</td>
      <td align="center">🐍</td>
      <td><strong>/python/</strong><br/>Controller interface & logic</td>
    </tr>
  </table>
</div>

---

## 🎮 Controls

- **Effect Parameters**: Size, speed, polygon sides
- **Color Controls**: Multiple modes, hue, brightness, saturation
- **Motion**: Rotation, zoom, mouse interaction
- **Text**: Multi-line support, effects, RGB split
- **Background**: Multiple stages, ghost effect, recording

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

<div align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://creativecommons.org/licenses/by-sa/2.0/">
          <img src="https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-sa.svg" alt="CC BY-SA License">
        </a>
      </td>
      <td>
        This project is licensed under the <a href="https://creativecommons.org/licenses/by-sa/2.0/">Creative Commons Attribution-ShareAlike 2.0 license</a>, following the Processing Foundation's licensing terms.
        <br/><br/>
        You are free to:<br/>
        ✅ Share — copy and redistribute the material in any medium or format<br/>
        ✅ Adapt — remix, transform, and build upon the material
        <br/><br/>
        Under the following terms:<br/>
        📝 Attribution — You must give appropriate credit<br/>
        🔄 ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license
      </td>
    </tr>
  </table>
</div>

---

<div align="center">
  <p>Made with ❤️ using Processing and Python</p>
</div> 