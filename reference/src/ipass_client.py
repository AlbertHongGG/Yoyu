from typing import Optional, Dict, Any
from .http_client import BaseHttpClient
from .logger import JsonFileLogger

class IPassClient:
    BASE_URL = "https://www.i-pass.com.tw/APP/APPV2"

    def __init__(self, log_dir: Optional[str] = None):
        logger = JsonFileLogger(log_dir) if log_dir else None
        self.http_client = BaseHttpClient(logger=logger)
        self._setup_default_headers()

    def _setup_default_headers(self):
        headers = {
            'Device-OS': 'Android',
            'OS-Version': '28',
            'App-Version': '1.36.0',
            'Accept-Language': 'zh-TW',
            'Accept': 'application/json',
            'User-Agent': 'ktor-client',
            'Content-Type': 'application/json',
            'Host': 'www.i-pass.com.tw',
            'Connection': 'Keep-Alive',
            'Accept-Encoding': 'gzip'
        }
        self.http_client.set_default_headers(headers)

    def check_my_card(self, card_no: str) -> Dict[str, Any]:
        url = f"{self.BASE_URL}/CheckMyCard"
        payload = {"cardNo": card_no}
        response = self.http_client.request('POST', url, json=payload)
        response.raise_for_status()
        return response.json()

    def check_my_cards(self, card_nos: list[str]) -> Dict[str, Any]:
        url = f"{self.BASE_URL}/CheckMyCards"
        payload = {"cardNos": card_nos}
        response = self.http_client.request('POST', url, json=payload)
        response.raise_for_status()
        return response.json()

    def get_inquire_detail(self, s_date: str, e_date: str, card_no: str) -> Dict[str, Any]:
        url = f"{self.BASE_URL}/GetInquireDetail"
        payload = {
            "sDate": s_date,
            "eDate": e_date,
            "cardNo": card_no
        }
        response = self.http_client.request('POST', url, json=payload)
        response.raise_for_status()
        return response.json()

    def get_inquire_catalog(self, s_date: str, e_date: str, card_no: str) -> Dict[str, Any]:
        url = f"{self.BASE_URL}/GetInquireCatalog"
        payload = {
            "sDate": s_date,
            "eDate": e_date,
            "cardNo": card_no
        }
        response = self.http_client.request('POST', url, json=payload)
        response.raise_for_status()
        return response.json()
