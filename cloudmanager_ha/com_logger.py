#!/usr/bin/env python

import time
import sys
import os
import logging
import string
from logging.handlers import RotatingFileHandler

LOG_FILE="/var/log/cloud/cloudmanager_ha.log"
logger=logging.getLogger()
handler = logging.handlers.RotatingFileHandler(LOG_FILE, maxBytes = 1024*1024, backupCount = 5)
formatter = logging.Formatter('%(asctime)s %(filename)s:%(lineno)d [%(levelname)s] %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

#console = logging.StreamHandler()
#console.setFormatter(formatter)
#logging.getLogger('').addHandler(console)  

logger.setLevel(logging.DEBUG)
#logger.setLevel(logging.INFO)


