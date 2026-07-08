# Developer Documentation

## Prerequisites

Install these on the VM before anything else:

```bash
sudo apt update
sudo apt instal -y docker.io docer-compose-plugin make git
sudo usermod -aG docker $USER
newgrp docker
```

## Environment setup from scratch

### 1. Clone the Repository

```bash
git clone git@github.com:alex-henriques/Inception.git
cd Inception
```

### 2. Create secrets (manually, not in git)

```bash
mkdir -p secrets
echo "db_pass" > secrets/db_pass.txt
echo "root_db_pass" > secrets/db_root_pass.txt
echo "admin_pass" > secrets/credentials.txt
```

### 3. Create srcs/.env (manually, not in git)

```bash
cat > srcs/.env << 'ENVEOF'
DOMAIN_NAME=alehenri.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=alehenri
WP_ADMIN_EMAIL=alehenri@student.42luxembourg.lu
WP_USER=visitor
WP_USER_EMAIL=visitor@alehenri.42.fr
ENVEOF
```

## Building & Launching

```bash
make
```
This will:
-> Create '/home/alehenri/data/mysql' and '/home/alehenri/data/wordpress' on the host;
-> Build all three Docker images from their Dockerfiles;
-> Start all containers in detached mode, under the name 'inception'.

First build can take 2 to 3 minutes; following builds are faster due to layer caching.

The project name flag '-p inception' must always be apassed to any manual 'docker compose' command. The Makefile always uses it internally, and every command below as well; omitting it will not give out an error but it will not give the right information.

## Managing Containers

```bash
# See running containers and their status
docker compose -f srcs/docker-compose.yml ps
# Stream all logs
make logs
# Restart a single service without rebuilding
docker compose -f srcs/docker-compose.yml restart wordpress
# Rebuild and restart a single service
docker compose -f srcs/docker-compose.yml up -d --build wordpress
# Open a shell inside a running container
docker exec -it inception-wordpress-1 sh
docker exec -it inception-mariadb-1 sh
docker exec -it inception-nginx-1 sh
# Connect to MariaDB directly
docker exec -it mariadb mysql -u root -p
```

## Accessing the WebSite

42 Machines don't allow sudo access, so '/etc/hosts' can't be edited. To solve this we need to use the DNS override flag instead.
The VM's IP address might change between reboots depending on the VM's network configuration (NAT/DHCP). Always check before launching the browser.

### 1. Point the domain to the VM (access to 'sudo'):

- On a machine with 'sudo" access, add it to '/etc/hosts':

```bash
echo "127.0.0.1 alehenri.42.fr" | sudo tee -a /etc/hosts
```

### 2. Launch the browser with a DNS override (no access to 'sudo')

-> Inside the VM:

 ```bash
 ip a
 ```
Look for the IP on the active network interface (e.g. '10.x.x.x)

-> From the host machine (not the VM), run one of the following, replacing 10.x.x.x with one of the following:
```
-> brave-browser --host-resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr
-> chromium --host-resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr
-> google-chrome --host-resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr
```

### 4. Go to Website

- 'https://alehenri.42.fr' should load the WP site correctly
- 'http://alehenri.42.fr' (port 80) should fail to connect. (NGINX only listens on port 443)


## Managing Volumes

```bash
#List all Docker volumes
docker volume ls
# Inspect a volume (shows host mount path)
docker volume inspect srcs_db_data
docker volume inspect srcs_wp_data
```

### Where data is stored

-> MariaDB databases:
	-> Container path:		/var/lib/mysql
	-> Host path:			/home/alehenri/data/mysql
-> WordPress files:
	-> Container path:		/var/www/html
	-> Host path:			/home/alehenri/data/wordpress

Data persists across 'make down' and 'make' cycles. To Wipe all data and start fresh:

```bash
make clean
make
```

Note: 'make fclean' does the same as 'make clean', plus removes this project's own Docker images. It doesn't touch images belonging to other projects, but it's advisable not to run 'make fclean' before an evaluation because it wipes the WP database and forces a full rebuild from scratch, which takes a few minutes.

EOF
