import time
import requests
from typing import Dict, Any, Optional

class BaseHttpClient:
    def __init__(self, logger=None):
        self.session = requests.Session()
        self.logger = logger

    def set_default_headers(self, headers: Dict[str, str]):
        self.session.headers.update(headers)

    def request(self, method: str, url: str, **kwargs) -> requests.Response:
        start_time = time.time()
        
        # Prepare request info for logging
        request_headers = {**self.session.headers, **kwargs.get('headers', {})}
        request_info = {
            "method": method,
            "url": url,
            "headers": dict(request_headers),
            "body": kwargs.get('json') or kwargs.get('data')
        }

        response = None
        error = None
        try:
            response = self.session.request(method, url, **kwargs)
            return response
        except Exception as e:
            error = str(e)
            raise
        finally:
            end_time = time.time()
            duration_ms = (end_time - start_time) * 1000

            response_info = {}
            if response is not None:
                try:
                    resp_body = response.json()
                except ValueError:
                    resp_body = response.text

                response_info = {
                    "status_code": response.status_code,
                    "headers": dict(response.headers),
                    "body": resp_body
                }
            elif error:
                response_info = {
                    "error": error
                }

            metadata = {
                "start_time": start_time,
                "end_time": end_time,
                "duration_ms": duration_ms
            }

            if self.logger:
                self.logger.log_api_call(request_info, response_info, metadata)
