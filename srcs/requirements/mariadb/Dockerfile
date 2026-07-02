#alpine 3.19 because it's the most stable one, 3.20 is the newest version

FROM	alpine:3.19

#installing packages; mariadb(database); mariadb-client(msqladmin and mysql CLI tools, used in setup), combined into one run to keep the layer count low

RUN	apk update && apk add --no-cache mariadb mariadb-client

#/run/mysql -> unix socket file lives
#/var/lib/mysql -> data directory (volume)
#chown both to the mysql user so the process can be written there
#the mysql yser is created automatically when mariadb is installed

RUN	mkdir -p /run/mysqld /var/lib/mysql && chown -R mysql:mysql /run/mysqld && chown -R mysql:mysql /var/lib/mysql

# configuration: copy my.cnf into the directory MariaDB reads on startup

COPY	conf/my.cnf /etc/my.cnf

#Entrypoint script
#copy the setup script and make it executable

COPY	tools/setup_db.sh /usr/local/bin/setup_db.sh
RUN	chmod +x /usr/local/bin/setup_db.sh

#secrets: Docker secrets are mounted at /run/secrets at runtime. Declared here so it can expect them. The actual file for secrets is docker-compose.yml
#Expose port 3306 for the docker network not the host.

EXPOSE	3306

#Entrypoint is the fixed command that always runs. CMD provides arguments to it. 

ENTRYPOINT	["/usr/local/bin/setup_db.sh"]