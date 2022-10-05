# docker-postgresql
# based on https://github.com/cthulhuology/docker-postgresql (few tweaks here and there)

FROM centos

### 1. Installs fresh Postgres
# install pg repo
RUN rpm -i http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
# install server
RUN yum install -y postgresql93-server postgresql93-contrib

### 2. Initialize DB data files
RUN su - postgres -c '/usr/pgsql-9.3/bin/initdb -D /var/lib/pgsql/9.3/data -U postgres --locale=pl_PL.UTF-8'

### 3. Expose database and it's port to host machine
# set permissions to allow logins, trust the bridge, this is the default for docker YMMV
RUN echo "host    all             all             172.17.42.1/16            trust" >> /var/lib/pgsql/9.3/data/pg_hba.conf
#listen on all interfaces
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/9.3/data/postgresql.conf
#expose 5432
EXPOSE 5432

### 4. Creates initial empty database and database user
# Switches user executing next command
USER postgres
# Creates user and database
RUN /usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data -w start \
 && /usr/pgsql-9.3/bin/psql --command "CREATE USER mrp WITH SUPERUSER PASSWORD 'mrp';" \
 && /usr/pgsql-9.3/bin/createdb -O mrp mrp \
 && /usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data -w stop

### 5. Add VOLUMEs to allow persistence of database
VOLUME  ["/usr/pgsql-9.3", "/var/lib/pgsql/9.3/data"]

### 6. Starts database as soon as container is being started
CMD ["/usr/pgsql-9.3/bin/postgres", "-D", "/var/lib/pgsql/9.3/data/", "-i"]