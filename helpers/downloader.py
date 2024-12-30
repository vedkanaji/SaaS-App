import requests
from pathlib import Path

def download_to_local(url, output_path: Path, parent_mkdir: bool=True):
    if not isinstance(output_path, Path):
        raise ValueError(f"{output_path} must be valid path")
    if parent_mkdir:
        output_path.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        output_path.write_bytes(response.content)
        return True
    except requests.exceptions.RequestException as e:
        print(f"failed to download {url}: {e}")
        return False