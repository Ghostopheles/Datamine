import os
import struct

from typing import Optional

from dm_tools import FileDownloader


class FileReader:
    def __init__(self, format_string: Optional[str] = None):
        # child classes may define the format as a static class var or whatever it's called
        if not self.FORMAT:
            self.FORMAT = format_string

    def unpack(self, obj: bytes):
        return struct.unpack(self.FORMAT, obj)

    def read(self, file_path: str) -> bytes:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"{file_path} does not exist.")

        with open(file_path, "rb") as f:
            content = f.read()

        return content

    def read_by_fdid(self, fdid: int, overwrite: bool = False) -> bytes:
        folder = self.TYPE.lower() if self.TYPE else None
        file_path = FileDownloader.download(fdid, overwrite=overwrite, folder=folder)
        if not file_path:
            raise Exception("File is not real. Too bad!")

        if os.path.getsize(file_path) == 0:
            return

        return self.read(file_path)
