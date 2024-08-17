import httpx

from os.path import dirname, realpath, join

from dm_logging import get_logger

SHARED_CLIENT_HEADERS = {"User-Agent": "ghst/dm_tools-1.0"}
SELF_PATH = dirname(realpath(__file__))
CACHE_PATH = join(SELF_PATH, "cache")

logger = get_logger()

CACHED_GAME_VERSION = None


def get_latest_game_version() -> str:
    global CACHED_GAME_VERSION

    if CACHED_GAME_VERSION is None:
        with httpx.Client(http2=True, headers=SHARED_CLIENT_HEADERS) as client:
            res = client.get("https://wago.tools/api/builds/wow/latest")
            res.raise_for_status()

        data = res.json()
        CACHED_GAME_VERSION = data["version"]

    return CACHED_GAME_VERSION
