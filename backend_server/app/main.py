from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
import os
import random
from pathlib import Path
import mimetypes

from uvicorn.config import LOGGING_CONFIG

from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/image", response_class=FileResponse)
async def get_image():
    # Directory specified in the environment (defaults to 'images')
    dir_env = os.environ.get("IMAGE_DIRECTORY", "images")

    dir_path = Path(dir_env)
    # If a relative path was provided, resolve it relative to this file
    if not dir_path.is_absolute():
        dir_path = Path(__file__).resolve().parent / dir_path

    if not dir_path.exists() or not dir_path.is_dir():
        raise HTTPException(status_code=500, detail=f"image directory not found: {dir_path}")

    # Collect image files by common extensions
    patterns = ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.bmp", "*.tiff", "*.svg"]
    files = []
    for p in patterns:
        files.extend(dir_path.glob(p))

    files = [f for f in files if f.is_file()]
    if not files:
        raise HTTPException(status_code=404, detail="no images found")

    chosen = random.choice(files)

    # Let Starlette/Starlette's FileResponse set the content-type, but set it explicitly if detectable
    media_type, _ = mimetypes.guess_type(str(chosen))
    return FileResponse(path=str(chosen), media_type=media_type)


if __name__ == "__main__":
    import uvicorn
    LOGGING_CONFIG["formatters"]["default"]["fmt"] = "%(asctime)s [%(name)s] %(levelprefix)s %(message)s"
    LOGGING_CONFIG["formatters"]["access"]["fmt"] = "%(asctime)s [%(name)s] %(levelprefix)s %(client_addr)s - '%(request_line)s' %(status_code)s"

    uvicorn.run(app, host="0.0.0.0", port=8000)