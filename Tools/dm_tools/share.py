from os.path import dirname, realpath, join

from dm_logging import get_logger

SHARED_CLIENT_HEADERS = {"User-Agent": "ghst/dm_tools-1.0"}
SELF_PATH = dirname(realpath(__file__))
CACHE_PATH = join(SELF_PATH, "cache")
WAGO_FILE_DOWNLOAD_URL = "https://wago.tools/api/casc/{fdid}?download"

logger = get_logger()
