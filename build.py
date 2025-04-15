import os
import platform
import shutil
import sys
from PyInstaller.__main__ import run as pyinstaller_run


def build_executable():
    try:
        # Determine the operating system
        system = platform.system().lower()
        print(f"Building for {system}...")

        # Clean previous builds
        for folder in ["build", "dist"]:
            if os.path.exists(folder):
                print(f"Cleaning {folder} directory...")
                shutil.rmtree(folder)

        # Ensure the python directory exists
        if not os.path.exists("python/main.py"):
            raise FileNotFoundError("Could not find python/main.py")

        # Create the VideoEffects directory if it doesn't exist
        os.makedirs("VideoEffects", exist_ok=True)

        # Base arguments for all platforms
        args = [
            "python/main.py",
            "--name=VideoEffectsController",
            "--windowed",
            "--clean",
            "--add-data=README.md:.",
            "--add-data=VideoEffects:VideoEffects",
        ]

        # Platform specific arguments
        if system == "darwin":
            # macOS specific settings
            args.extend(
                [
                    "--target-arch=universal2",  # Build for both Intel and Apple Silicon
                    "--osx-bundle-identifier=com.videoeffects.controller",
                    "--codesign-identity=-",  # Skip code signing
                    "--hidden-import=tkinter",
                    "--hidden-import=tkinter.ttk",
                    # Don't use onefile mode on macOS as it can cause issues
                ]
            )
        else:
            # Windows and Linux can use onefile mode
            args.append("--onefile")

        # Add icon if available
        if system == "windows" and os.path.exists("assets/icon.ico"):
            args.append("--icon=assets/icon.ico")
        elif system == "darwin" and os.path.exists("assets/icon.icns"):
            args.append("--icon=assets/icon.icns")

        print("Starting PyInstaller build...")
        print("Build arguments:", " ".join(args))
        pyinstaller_run(args)

        # Create distribution folder
        dist_folder = f"VideoEffectsController-{system}"
        print(f"Creating distribution folder: {dist_folder}")
        os.makedirs(dist_folder, exist_ok=True)

        # Copy files to distribution folder
        if system == "windows":
            executable = "dist/VideoEffectsController.exe"
            if os.path.exists(executable):
                shutil.copy(executable, dist_folder)
        elif system == "darwin":
            executable = "dist/VideoEffectsController.app"
            if os.path.exists(executable):
                shutil.copytree(
                    executable,
                    f"{dist_folder}/VideoEffectsController.app",
                    dirs_exist_ok=True,
                )
                # Fix permissions for macOS app
                os.system(f"chmod -R +x {dist_folder}/VideoEffectsController.app")
        else:
            executable = "dist/VideoEffectsController"
            if os.path.exists(executable):
                shutil.copy(executable, dist_folder)
                # Make executable on Linux
                os.chmod(f"{dist_folder}/VideoEffectsController", 0o755)

        if not os.path.exists(executable):
            raise FileNotFoundError(f"Could not find built executable: {executable}")

        # Copy additional files
        print("Copying additional files...")
        shutil.copy("README.md", dist_folder)

        # Copy Processing sketch
        if os.path.exists("VideoEffects"):
            print("Copying Processing sketch...")
            shutil.copytree(
                "VideoEffects", f"{dist_folder}/VideoEffects", dirs_exist_ok=True
            )

        # Create ZIP archive
        print("Creating ZIP archive...")
        zip_name = f"{dist_folder}.zip"
        if os.path.exists(zip_name):
            os.remove(zip_name)
        shutil.make_archive(dist_folder, "zip", dist_folder)

        print(f"\nBuild complete! Distribution package created: {zip_name}")
        print("\nThe package includes:")
        print("1. The VideoEffectsController application")
        print("2. The Processing sketch (VideoEffects folder)")
        print("3. README with instructions")

        if system == "darwin":
            print("\nImportant notes for macOS users:")
            print("1. Right-click the app and select 'Open' the first time you run it")
            print(
                "2. If you get a security warning, go to System Preferences > Security & Privacy"
            )
            print("   and click 'Open Anyway'")

    except Exception as e:
        print(f"\nError during build: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    build_executable()
