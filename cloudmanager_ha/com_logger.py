#!/usr/bin/env python

import time
import sys
import os
import logging
import string

logger=logging.getLogger()
handler=logging.FileHandler("/var/log/cloudmanager_ha.log")
formatter = logging.Formatter('%(asctime)s %(filename)s:%(lineno)d [%(levelname)s] %(message)s')
#formatter = logging.Formatter('%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
console = logging.StreamHandler()
console.setFormatter(formatter)
logging.getLogger('').addHandler(console)  
logger.setLevel(logging.DEBUG)
#logger.setLevel(logging.INFO)


