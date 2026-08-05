import sys
import httpx
import logging

from dm_tools import SHARED_CLIENT_HEADERS

logger = logging.getLogger(__name__)


class FileDownloader:
    @staticmethod
    def download(fdid: int) -> bytes:
        logger.info(f"Downloading file {fdid} from wago.tools...")

        client = httpx.Client(
            base_url="https://wago.tools/api",
            headers=SHARED_CLIENT_HEADERS,
            http2=True,
            timeout=httpx.Timeout(30.0, connect=5.0),
        )

        res = client.get(f"/casc/{fdid}")
        if res.status_code != 200:
            logger.error(f"Failed to download file {fdid} from wago.tools, status code: {res.status_code}")
            return None

        data = res.read()
        if sys.getsizeof(data) == 0:
            logger.error(f"Downloaded file {fdid} is empty")

        return data
