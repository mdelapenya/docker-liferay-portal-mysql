
## Connecting to the bundled MySQL server from outside the container

The first time that you run the container, a new user `admin` with all privileges
will be created in MySQL with a random password. To get the password, check the logs
of the container by running:

```shell
docker logs $CONTAINER_ID
```

You will see an output like the following:

```shell
========================================================================
You can now connect to this MySQL Server using:

    mysql -uadmin -p47nnf4FweaKu -h<host> -P<port>

Please remember to change the above password as soon as possible!
MySQL user 'root' has no password but only allows local connections
========================================================================
```

In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

You can then connect to MySQL:

```shell
mysql -uadmin -p47nnf4FweaKu
```

Remember that the `root` user does not allow connections from outside the container -
you should use this `admin` user instead!

## Setting a specific password for the MySQL server admin account

If you want to use a preset password instead of a random generated one, you can
set the environment variable `MYSQL_PASS` to your specific password when running the container:

```shell
docker run -d -p 80:80 -p 3306:3306 -e MYSQL_PASS="mypass" mdelapenya/liferay-portal-mysql
```

You can now test your new admin password:

```shell
mysql -uadmin -p"mypass"
```