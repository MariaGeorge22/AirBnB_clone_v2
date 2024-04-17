#!/usr/bin/python3
"""
a Fabric script that generates a .tgz archive
from the contents of the web_static folder
of your AirBnB Clone repo,
using the function do_pack
"""

from datetime import datetime
from fabric.api import local


def do_pack():
    """
    generates a .tgz archive from the contents of the web_static folder
    """
    date = datetime.strftime(datetime.now(), "%Y%m%d%H%M%S")
    name = f"web_static_{date}.tgz"
    local("mkdir -p versions")
    result = local("tar -cvzf versions/{} web_static".format(name))
    if result.failed:
        return None
    return f'versions/{name}'
