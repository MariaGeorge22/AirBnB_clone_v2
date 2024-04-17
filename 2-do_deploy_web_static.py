#!/usr/bin/python3
"""
This python program creates archive on local machine,
deploy it to the target servers and unzip it with some
other cool stuffs
"""


from fabric.api import *
from os import path
from datetime import datetime


env.hosts = ['34.224.95.198', '52.87.220.62']
env.rsa = '~/.ssh/id_rsa'
env.user = 'ubuntu'


def do_deploy(archive_path):
    """Depoying web static
        :param archive_path: path to archive file

    """
    try:
        if not (path.exists(archive_path)):
            return False

        # uploading archive
        put(archive_path, '/tmp/')

        # Creating destination dir
        time = archive_path[-18:-4]
        run('sudo mkdir -p /data/web_static/releases/web_static_{}.tgz/'
            .format(time))

        # Uncompressing archive folder
        run('tar -xzf /tmp/web_static_{}.tgz -C /data/web_static/\
            releases/web_static_{}/'.format(time, time))

        # Delete the archive from the web server
        run('sudo rm /tmp/web_static_{}.tgz'.format(time))

        # Move files
        run('sudo mv /data/web_static/releases/web_static_{}/web_static/* \
            /data/web_static/releases/web_static_{}/'.format(time, time))

        # Remove an empty dir
        run('sudo rm -rf /data/web_static/releases/web_static_{}/\
            web_static'.format(time))

        # Delete the symbolic link /data/web_static/current from the web server
        run('sudo rm -rf /data/web_static/current')

        # Create a new the symbolic link /data/web_static/current on
        # the web server
        run('sudo ln -sfn /data/web_static/releases/web_static_{}.tgz/ \
            /data/web_static/current'.format(time))

    except Exception as e:
        # If failed
        return False

        # On Success
    return True
