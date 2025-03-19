import subprocess
import os
import logging
from fastapi import HTTPException
from services.whisper_service import transcribe_audio

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def convert_video_to_mp3(report_id, video_path=None):
    """
    Convert video to MP3 format.
    
    Args:
        report_id: The report ID to use for generating output paths
        video_path: Optional explicit path to the video file. If not provided,
                   the function will look for a video in a standardized location
    
    Returns:
        Path to the converted MP3 file
    """
    # Set up paths
    output_dir = f"tmp/audio/{report_id}"
    os.makedirs(output_dir, exist_ok=True)
    output_audio_path = f"{output_dir}/audio.mp3"
    
    # If video_path is provided, use it directly
    if video_path and os.path.exists(video_path):
        input_video_path = video_path
    else:
        # Use original behavior - locate video based on report_id
        video_dir = f"tmp/videos/{report_id}"
        
        # Find the first video file in the directory
        if os.path.exists(video_dir):
            video_files = [f for f in os.listdir(video_dir) if f.endswith(('.mp4', '.mov', '.avi', '.mkv'))]
            if video_files:
                input_video_path = f"{video_dir}/{video_files[0]}"
            else:
                raise FileNotFoundError(f"No video files found in {video_dir}")
        else:
            raise FileNotFoundError(f"Video directory not found: {video_dir}")
    
    # Execute ffmpeg command to convert video to MP3
    try:
        ffmpeg_cmd = [
            "ffmpeg", "-i", input_video_path, 
            "-vn",  # No video
            "-ar", "44100",  # Audio sampling rate
            "-ac", "2",  # Audio channels
            "-ab", "192k",  # Audio bitrate
            "-f", "mp3",  # Output format
            output_audio_path
        ]
        
        # Run the command
        result = subprocess.run(ffmpeg_cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            logging.error(f"FFMPEG error: {result.stderr}")
            raise Exception(f"Failed to convert video to MP3: {result.stderr}")
        
        return output_audio_path
        
    except Exception as e:
        logging.error(f"Error converting video to MP3: {str(e)}")
        raise

def transcribe_audio_to_text(report_id: str):
    try:
        # Define the audio file path
        audio_file_path = f"res/audio/{report_id}_audio.mp3"

        # Transcribe the audio
        transcription, _ = transcribe_audio(audio_file_path)

        if not transcription:
            raise HTTPException(status_code=404, detail="Transcription failed or returned empty.")

        output_file = f"res/transcription/{report_id}_transcription.txt"
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(transcription)
        logger.info(f"Transcription saved to '{output_file}'.")

        return transcription

    except Exception as e:
        # Handle other potential errors
        logger.error(f"An error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
