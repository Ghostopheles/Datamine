import sys
import httpx

from dm_tools import SHARED_CLIENT_HEADERS, logger


class FileDownloader:
    def __init__(self):
        self.client = httpx.Client(
            base_url="https://wago.tools/api",
            headers=SHARED_CLIENT_HEADERS,
            http2=True,
            follow_redirects=True
        )

    def download(self, fdid: int) -> bytes:
        logger.info(f"Downloading file {fdid} from wago.tools...")

        res = self.client.get(f"/casc/{fdid}")
        res.raise_for_status()

        data = res.read()
        if sys.getsizeof(data) == 0:
            logger.error(f"Downloaded file {fdid} is empty")

        return data
