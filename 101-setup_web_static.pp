# This program will install Nginx and Put a static file in it.
# This bash script will automate the creation of files.

exec {'run':
	command	=>  "sudo apt update && sudo apt-get install nginx -y"
}

exec { 'ufw':
    command =>  "sudo ufw allow 'Nginx HTTP'"
}

# Creating All Required Folders and File
exec { 'files_folder':
    commnad sudo mkdir -p /data/web_static/releases
sudo mkdir -p /data/web_static/shared
sudo mkdir -p /data/web_static/releases/test
#sudo mkdir -p /data/web_static/current
sudo touch /data/web_static/releases/test/index.html

PATH_F=/data/web_static/releases/test/index.html

# Adding a Test Content to index file
CONTENT="<html>
<head>
</head>
<body>
    Holberton School
</body>
</html>"

echo "$CONTENT" | sudo tee "$PATH_F"

# Creating A Symbolic Linking
sudo ln -sfn /data/web_static/releases/test/ /data/web_static/current

# Granting Ownership
sudo chown -R ubuntu:ubuntu /data/

# Here is the section that configures Nginx Config file
CONF_PATH=/etc/nginx/sites-enabled/default

sudo sed -i "/listen 80 default_server;/a\\\tlocation /hbnb_static/ {\n\talias /data/web_static/current/;\n\t}" "$CONF_PATH"

sudo service nginx restart
