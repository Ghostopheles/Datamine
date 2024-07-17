import struct
import logging
import pycasclib.core as casc

from typing import Optional

logger = logging.getLogger("dm_tools")


class FileReader:
    FORMAT = None
    PRODUCT = None
    CASC_PATH = None

    def __init__(self, format_string: Optional[str] = None):
        # child classes may define the format as a static class var or whatever it's called
        if not self.FORMAT:
            self.FORMAT = format_string

        if not self.PRODUCT:
            self.PRODUCT = "wow_beta"

        is_online = False
        locale = casc.LocaleFlags.CASC_LOCALE_ENUS
        logger.info(
            f"Opening Casc handle with locale={locale}, product={self.PRODUCT}, online={is_online}"
        )
        self.casc = casc.CascHandler(
            self.CASC_PATH, locale, product=self.PRODUCT, is_online=is_online
        )

    def unpack(self, obj: bytes):
        return struct.unpack(self.FORMAT, obj)

    def read_by_fdid(self, fdid: int) -> bytes:
        fdid = int(fdid)
        open_flags = casc.FileOpenFlags.CASC_OPEN_BY_FILEID
        if not self.casc.file_exists(fdid, open_flags):
            logger.warning(f"File {fdid} does not exist")
            return

        logger.info(f"Reading file {fdid}")
        file = self.casc.read_file_by_id(fdid, open_flags)
        return file.data
