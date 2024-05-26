import os
import io
import httpx
import zipfile

# from dm_tools import SHARED_CLIENT_HEADERS, CACHE_PATH, logger

emotes_dbd_url = (
    "https://raw.githubusercontent.com/wowdev/WoWDBDefs/master/definitions/Emotes.dbd"
)

dbd_url = "https://github.com/wowdev/WoWDBDefs/archive/refs/heads/master.zip"

client = httpx.Client(http2=True, follow_redirects=True)

DBD_PATH = os.path.join(os.path.dirname(__file__), "cache", "dbd")


class DBDefs:
    def __init__(self):
        if not os.path.exists(DBD_PATH):
            os.makedirs(DBD_PATH, exist_ok=True)
            self.download_dbdefs()

    def download_dbdefs(self):
        response = client.get(dbd_url)
        response.raise_for_status()

        with open("dbd.zip", "wb") as f:
            for chunk in response.iter_bytes():
                f.write(chunk)

        file = zipfile.ZipFile("dbd.zip", "r")
        file.extractall()

        os.remove("dbd.zip")


DBDefs()
