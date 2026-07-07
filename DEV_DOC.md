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
echo "<db_password>" > secrets/db_pass.txt
echo "<root_db_password>" > secrets/db_root_pass.txt
echo "<admin_password>" > secrets/credentials.txt
```

### 3. Create srcs/.env (manually, not in git)

```bash
cat > srcs/.env << 'ENVEOF'
DOMAIN_NAME=alehenri42
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
-> Start all containers in detached mode.

First build can take 2 to 3 minutes; following builds are faster due to layer caching.

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
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it nginx sh
# Connect to MariaDB directly
docker exec -it mariadb mysql -u root -p
```

## Accessing the WebSite

42 Machines don't allow sudo access, so '/etc/hosts' can't be edited. To resolve this we'll have to use the browser's built-in DNS override flag instead.
The VM's IP address might change between reboots depending on the VM's network configuration (NAT/DHCP). Always check before launching the browser.

### 1. Get the VM's IP address

Inside the VM:
 ```bash
 ip a
 ```
Look for the IP on the active network interface (e.g. '10.x.x.x)

### 2. Launch the browser with a DNS override

From the host machine (not the VM), run one of the following, replacing 10.x.x.x with one of the following:
-> brave-browser --host -resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr
-> chromium --host -resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr
-> google-chrome --host -resolver-rules="MAP alehenri.42.fr 10.x.x.x" https://alehenri.42.fr

### 3. Verification

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

## Project Structure

Inception/
├── Makefile
├── .gitignore
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
├── .env (not in git)
├── docker-compose.yml
└── requirements/
├── mariadb/
│ ├── Dockerfile
│ ├── conf/my.cnf
│ └── tools/setup_db.sh
├── wordpress/
│ ├── Dockerfile
│ ├── conf/www.conf
│ └── tools/setup_wordpress.sh
└── nginx/
├── Dockerfile
├── conf/nginx.conf
└── tools/generate_cert.sh

EOF