#!/usr/bin/env bash
# Sets up your web server for the deployment of web_static

# Colors for formatting output
red='\e[0;31m'
brown='\e[0;33m'
green='\e[1;32m'
blue='\e[1;34m'
reset='\033[0m'

# Function to install packages
function install() {
    if command -v "$1" &> /dev/null ; then
        echo -e "    ${green}Package already installed: ${brown}${1}${reset}"
    else
        echo -e "    Installing: ${brown}$1${reset}"
        sudo apt-get update -y -qq && sudo apt-get install -y "$1" -qq
        echo -e "\n"
    fi
}

# Function to create directories
function create_directory() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        mkdir -p "$directory"
    else
        echo -e "    ${green}Directory already exists: ${brown}$directory${reset}"
    fi
}

# Create or recreate the symbolic link
function recreate_symbolic_link () {
    local directory="/data/web_static/releases/test/"
    local symbolic_link="/data/web_static/current"

    if [ -L "$symbolic_link" ]; then
      echo -e "    ${green}symbolic link already exist -> ${brown}$symbolic_link : Removing...${reset}"
      sudo rm "$symbolic_link"
    fi
    echo -e "    ${green}Creating new symbolic link -> ${brown}$symbolic_link${reset}"
    sudo ln -s "$directory" "$symbolic_link"
}

# Function to create html file
function create_html_file() {
    local file_path="/data/web_static/releases/test/index.html"
    local content="<html>\n  <head>\n  </head>\n  <body>\n    Holberton School\n  </body>\n</html>"
    echo -e "$content" > "$file_path"
}

# Function to Check/Update /data/ ownership.
function check_owner() {
    local owner
    local group
    local expected_owner="ubuntu"
    local expected_group="ubuntu"

    owner=$(stat -c "%U" "/data/")
    group=$(stat -c "%G" "/data/")

    if [ "$owner" != "$expected_owner" ] || [ "$group" != "$expected_group" ]; then
        echo -e "    ${blue}Changing ownership of ${brown}/data/ to $owner:$group...${reset}"
        sudo chown -R ubuntu:ubuntu /data/ || handle_error 1 "Failed to change ownership of /data/"
    else
        echo -e "    ${green}Ownership of ${brown}/data/ ${green}is already set: ${brown}$owner:$group.${reset}"
    fi
}

# Function for updating nginx config
function update_nginx_config() {
    local config_file="/etc/nginx/sites-available/default"

    # Backup the current configuration file if backup doesn't exist
    if [ ! -f "${config_file}_$(date +%Y%m%d%H%M%S).backup" ]; then
        sudo cp "$config_file" "${config_file}_$(date +%Y%m%d%H%M%S).backup"
        echo -e "    ${green}Backed up the current configuration file to ${brown}${config_file}_$(date +%Y%m%d%H%M%S).backup${reset}"
    fi

    # Remove any existing configuration for serving hbnb_static
    sudo sed -i '/location \/hbnb_static {/,/}/d' "$config_file"

    local config="location /hbnb_static {\n\talias /data/web_static/current/;}"

    # Add new configuration for serving hbnb_static using alias
    sudo sed -i "/server_name _;/a\\$config" "$config_file"
}

# Function to restart nginx service.
function restart_nginx() {
    sudo service nginx restart
}

# Error handling function
function handle_error() {
    local exit_code="$1"
    local error_message="$2"
    echo -e "${red}Error: ${error_message}${reset}"
    exit "$exit_code"
}

# Array of packages to install
packages=(
    "nginx"
)

# Array of directories to create
directories=(
    "/data/"
    "/data/web_static/"
    "/data/web_static/releases/"
    "/data/web_static/shared/"
    "/data/web_static/releases/test/"
)

echo -e "${blue}Setting up your web server & doing some minor checks...${reset}"

# Install packages
for package in "${packages[@]}"; do
    install "$package" || handle_error 1 "Failed to install package: $package"
done

# Create the directories
for directory in "${directories[@]}"; do
    create_directory "$directory" || handle_error 1 "Failed to create directory: $directory"
done

# Create the fake HTML file
create_html_file || handle_error 1 "Failed to create HTML file"

# Create or recreate the symbolic link
recreate_symbolic_link || handle_error 1 "Failed to create symbolic link"

# Check and update ownership of /data/ to ``ubuntu``
check_owner

echo -e "${blue}Updating Nginx configuration.${reset}"

# Update Nginx configuration
update_nginx_config || handle_error 1 "Failed to update Nginx configuration"

# Restart Nginx
restart_nginx || handle_error 1 "Failed to restart Nginx"

echo -e "${blue}[✔] D O N E${reset}"
# Successful exit
exit 0
