#!/usr/bin/python3
"""
This is a python porgram that uses Fabric to Tranfer
file to my server, by first compressing it.
"""

from fabric.api import local
from time import strftime
from datetime import time


def do_pack():
    """
    do_pack funtion or method will create a folder called
    version and create web_static achive in it with date
    """
    filedate = strftime("%Y%m%d%H%M%S")
    try:
        local("mkdir -p versions")
        local("tar -czvf versions/web_static_{}.tgz web_static".format(
            filedate))
        return "versions/web_static_{}.tgz".format(filedate)

    except Exception as e:
        return None
