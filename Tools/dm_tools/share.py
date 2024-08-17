import httpx

from os.path import dirname, realpath, join

from dm_logging import get_logger

SHARED_CLIENT_HEADERS = {"User-Agent": "ghst/dm_tools-1.0"}
SELF_PATH = dirname(realpath(__file__))
CACHE_PATH = join(SELF_PATH, "cache")

logger = get_logger()


def get_latest_build() -> str:
    with httpx.Client(http2=True, headers=SHARED_CLIENT_HEADERS) as client:
        res = client.get("https://wago.tools/api/builds/wow/latest")
        res.raise_for_status()

    data = res.json()
    return data["version"]
