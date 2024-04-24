import os
import csv
import time
import httpx

from dm_tools import SHARED_CLIENT_HEADERS, CACHE_PATH, logger

LISTFILE_URL = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
LISTFILE_PATH = os.path.join(CACHE_PATH, "community_listfile.csv")
LISTFILE_DIALECT_NAME = "listfile"

CACHE_PERIOD = 86400  # 24 hours


class ListfileDialect(csv.Dialect):
    """CSV dialect for the community listfile"""

    delimiter = ";"
    quotechar = '"'
    doublequote = True
    skipinitialspace = False
    lineterminator = "\r\n"
    quoting = csv.QUOTE_MINIMAL


csv.register_dialect(LISTFILE_DIALECT_NAME, ListfileDialect)


class Listfile:
    @staticmethod
    def should_update() -> bool:
        # if the listfile doesn't exist, update (duh)
        if not os.path.exists(LISTFILE_PATH):
            return True

        # if our listfile is > 24 hours old, update it
        last_modified = os.path.getmtime(LISTFILE_PATH)
        if (time.time() - last_modified) > CACHE_PERIOD:
            return True

        return False

    @staticmethod
    def update() -> bool:
        logger.info("Updating listfile...")
        res = httpx.get(
            LISTFILE_URL, headers=SHARED_CLIENT_HEADERS, follow_redirects=True
        )
        if res.status_code != 200:
            logger.error(
                f"Non-200 status code received while updating listfile: {res.status_code}"
            )
            return False

        with open(LISTFILE_PATH, "wb") as f:
            f.write(res.read())

        logger.info("Listfile updated and saved to cache.")
        return True

    @staticmethod
    def read():
        if Listfile.should_update():
            success = Listfile.update()
            if not success:
                raise Exception("Error updating listfile")

        with open(LISTFILE_PATH, "r") as f:
            reader = csv.reader(f, dialect=LISTFILE_DIALECT_NAME)
            for row in reader:
                yield int(row[0]), row[1]

    @staticmethod
    def get_name_for_fdid(search_fdid: int) -> str:
        for id, name in Listfile.read():
            if id == search_fdid:
                return name

    @staticmethod
    def get_fdid_for_name(search_name: str) -> int:
        for id, name in Listfile.read():
            if name == search_name:
                return id
