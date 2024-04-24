import os
import sys
import json
import logging
import logging.config

logger = logging.getLogger("datamine-tools")

self_path = os.path.dirname(os.path.realpath(__file__))

with open(os.path.join(self_path, "cfg.json")) as f:
    log_config = json.load(f)
logging.config.dictConfig(log_config)

logger.info(f"Using Python version {sys.version}")


def get_logger():
    return logger
