import json
import os
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any

class JsonFileLogger:
    def __init__(self, log_dir: str):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)

    def log_api_call(self, request_info: Dict[str, Any], response_info: Dict[str, Any], metadata: Dict[str, Any]):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        # Extract a simple name from URL for the log file prefix
        url = request_info.get("url", "")
        endpoint_name = url.split("/")[-1].split("?")[0] if url else "api"
        
        filename = f"{timestamp}_{endpoint_name}.json"
        filepath = self.log_dir / filename

        log_data = {
            "metadata": metadata,
            "request": request_info,
            "response": response_info
        }

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, ensure_ascii=False, indent=2)
