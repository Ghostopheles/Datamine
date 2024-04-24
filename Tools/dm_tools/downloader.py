import os
import sys
import httpx

from dm_tools import SHARED_CLIENT_HEADERS, CACHE_PATH, logger


class FileDownloader:
    client = httpx.Client(
        base_url="https://wago.tools/api",
        headers=SHARED_CLIENT_HEADERS,
        http2=True,
    )
    cache_dir = CACHE_PATH

    @staticmethod
    def check_cache_dir():
        if not os.path.exists(FileDownloader.cache_dir):
            os.makedirs(FileDownloader.cache_dir)

    @staticmethod
    def download(fdid: int, overwrite: bool = False, folder: str = None) -> str:
        logger.info(f"Downloading file {fdid}...")

        if folder:
            out_path = os.path.join(FileDownloader.cache_dir, folder)
        else:
            out_path = FileDownloader.cache_dir

        if not os.path.exists(out_path):
            os.makedirs(out_path, exist_ok=True)

        out_path = os.path.join(out_path, str(fdid))

        if os.path.exists(out_path) and not overwrite:
            logger.info(f"File {fdid} is already cached, returning file from cache")
            return out_path

        _client = httpx.Client(
            base_url="https://wago.tools/api",
            headers=SHARED_CLIENT_HEADERS,
            http2=True,
        )

        res = _client.get(f"/casc/{fdid}")
        if res.status_code != 200:
            logger.error(
                f"Non-200 status code received while downloading file {fdid}: {res.status_code}"
            )
            return

        data = res.read()
        if sys.getsizeof(data) == 0:
            logger.error(f"File {fdid} has size 0")

        with open(out_path, "wb") as f:
            logger.info(f"Saving file {fdid}")
            f.write(res.read())

        return out_path
