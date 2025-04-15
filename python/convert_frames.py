import os
import glob
import ffmpeg
from pathlib import Path


def find_latest_frame_sequence():
    """Find the most recently modified frame sequence in the project."""
    patterns = ["output/frame-*.png", "frames/frame-*.png"]

    latest_sequence = None
    latest_time = 0

    for pattern in patterns:
        frames = sorted(glob.glob(pattern))
        if frames:
            # Check modification time of the last frame
            mtime = os.path.getmtime(frames[-1])
            if mtime > latest_time:
                latest_time = mtime
                directory = os.path.dirname(pattern)
                latest_sequence = {
                    "pattern": f"{directory}/frame-%06d.png",
                    "count": len(frames),
                    "frames": frames,
                }

    return latest_sequence


def convert_frames_to_mp4(
    input_pattern, output_file, framerate=30, delete_frames=False
):
    """
    Convert a sequence of image frames to an MP4 video file.

    Args:
        input_pattern (str): Pattern for input frames (e.g., 'output/frame-%06d.png')
        output_file (str): Path to the output MP4 file
        framerate (int): Frame rate of the output video
        delete_frames (bool): Whether to delete the original frames after conversion

    Returns:
        dict: Information about the conversion including output file path and compression stats
    """
    try:
        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

        # Build the ffmpeg command
        stream = (
            ffmpeg.input(input_pattern, pattern_type="sequence", framerate=framerate)
            .output(
                output_file,
                vcodec="libx264",
                pix_fmt="yuv420p",
                preset="medium",
                crf=23,
            )
            .overwrite_output()
        )

        # Run the ffmpeg command
        stream.run(capture_stdout=True, capture_stderr=True)

        # Get file sizes for stats
        frame_files = glob.glob(input_pattern.replace("%06d", "*"))
        frames_size = sum(os.path.getsize(f) for f in frame_files) / (1024 * 1024)  # MB
        video_size = os.path.getsize(output_file) / (1024 * 1024)  # MB

        # Delete original frames if requested
        if delete_frames:
            for frame in frame_files:
                os.remove(frame)

        return {
            "success": True,
            "output_file": output_file,
            "frame_count": len(frame_files),
            "frames_size_mb": frames_size,
            "video_size_mb": video_size,
            "compression_ratio": frames_size / video_size if video_size > 0 else 0,
            "frames_deleted": delete_frames,
        }

    except ffmpeg.Error as e:
        return {
            "success": False,
            "error": f"FFmpeg error:\nstdout: {e.stdout.decode('utf8')}\nstderr: {e.stderr.decode('utf8')}",
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


def auto_convert_latest_sequence(framerate=30, delete_frames=False):
    """
    Automatically find and convert the most recent frame sequence.

    Args:
        framerate (int): Frame rate for the output video
        delete_frames (bool): Whether to delete original frames after conversion

    Returns:
        dict: Conversion results and statistics
    """
    sequence = find_latest_frame_sequence()
    if not sequence:
        return {"success": False, "error": "No frame sequences found"}

    output_file = os.path.join(os.path.dirname(sequence["pattern"]), "output.mp4")
    return convert_frames_to_mp4(
        sequence["pattern"],
        output_file,
        framerate=framerate,
        delete_frames=delete_frames,
    )


if __name__ == "__main__":
    # When run directly, convert latest sequence and print results
    result = auto_convert_latest_sequence(framerate=30, delete_frames=False)
    if result["success"]:
        print(
            f"Successfully converted {result['frame_count']} frames to: {result['output_file']}"
        )
        print(f"\nStatistics:")
        print(f"Total frames size: {result['frames_size_mb']:.2f} MB")
        print(f"Video file size: {result['video_size_mb']:.2f} MB")
        print(f"Compression ratio: {result['compression_ratio']:.2f}x")
        if result["frames_deleted"]:
            print(f"Original frames were deleted")
    else:
        print(f"Error during conversion: {result['error']}")
