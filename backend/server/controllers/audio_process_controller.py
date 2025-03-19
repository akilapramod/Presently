import logging
from fastapi import APIRouter, HTTPException, Query
from services.audio_processing import convert_video_to_mp3, transcribe_audio_to_text

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/convert_to_mp3")
async def convert_to_mp3(report_id: str = Query(...), video_path: str = Query(None)):
    try:
        # If video_path is provided, pass it to the conversion function
        if video_path:
            output_audio_path = convert_video_to_mp3(report_id, video_path)
        else:
            # Fallback to original behavior where it finds the video using report_id
            output_audio_path = convert_video_to_mp3(report_id)
            
        return {"message": f"Successfully converted video to MP3. File saved at: {output_audio_path}"}

    except HTTPException as e:
        logger.error(f"HTTP Exception: {e.detail}")
        raise
    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/transcribe")
async def transcribe(report_id: str = Query(...)):
    try:
        transcription = transcribe_audio_to_text(report_id)
        return {"transcription": transcription}

    except HTTPException as e:
        logger.error(f"HTTP Exception: {e.detail}")
        raise
    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
