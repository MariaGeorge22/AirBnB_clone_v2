#!/usr/bin/python3
""" Fabric script (based on the file 1-pack_web_static.py)
that distributes an archive to your web servers """

import time
from fabric.api import sudo, put, env, local
from os.path import exists, isdir


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


def do_deploy(archive_path):
    """ A function that distributes an archive to your web servers """
    try:
        if exists(archive_path):
            file_name = archive_path.split("/")[-1]
            file_no_ext = file_name.split(".")[0]
            path = "/data/web_static/releases/"
            put(archive_path, '/tmp/')
            sudo('mkdir -p {}{}/'.format(path, file_no_ext))
            sudo('tar -xzf /tmp/{} -C {}{}/'.format(file_name,
                                                    path, file_no_ext))
            sudo('rm /tmp/{}'.format(file_name))
            sudo('mv {0}{1}/web_static/* {0}{1}/'.format(path, file_no_ext))
            sudo('rm -rf {}{}/web_static'.format(path, file_no_ext))
            sudo('rm -rf /data/web_static/current')
            sudo('ln -s {}{}/ /data/web_static/current'.format(
                path, file_no_ext))
            return True
        else:
            return False
    except Exception:
        return False


def deploy():
    """ A function that distributes an archive to your web servers """
    return do_deploy(do_pack())
