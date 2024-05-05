#!/usr/bin/python3
""" Fabric script that generates a .tgz archive """


import time
from fabric.api import local
from os.path import isdir


def do_pack():
    """ A function that generates a .tgz archive """
    try:
        file_name = "versions/web_static_{}.tgz".format(
            time.strftime("%Y%m%d%H%M%S"))
        if isdir("versions") is False:
            local("mkdir versions")
        local("tar -cvzf {} web_static".format(file_name))
        return file_name
    except Exception:
        return None
