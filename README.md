[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/big-data-europe/Lobby)

# docker-hive

This is a docker container for Apache Hive 2.3.2. It is based on https://github.com/big-data-europe/docker-hadoop so check there for Hadoop configurations.
This deploys Hive and starts a hiveserver2 on port 10000.
Metastore is running with a connection to postgresql database.
The hive configuration is performed with HIVE_SITE_CONF_ variables (see hadoop-hive.env for an example).

To run Hive with postgresql metastore:
```
    docker-compose up -d
```

To deploy in Docker Swarm:
```
    docker stack deploy -c docker-compose.yml hive
```

To run a PrestoDB 0.181 with Hive connector:

```
  docker-compose up -d presto-coordinator
```

This deploys a Presto server listens on port `8080`

## Testing
Load data into Hive:
```
  $ docker-compose exec hive-server bash
  # /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000
  > CREATE TABLE pokes (foo INT, bar STRING);
  > LOAD DATA LOCAL INPATH '/opt/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;
```

Then query it from PrestoDB. You can get [presto.jar](https://prestosql.io/docs/current/installation/cli.html) from PrestoDB website:
```
  $ wget https://repo1.maven.org/maven2/io/prestosql/presto-cli/308/presto-cli-308-executable.jar
  $ mv presto-cli-308-executable.jar presto.jar
  $ chmod +x presto.jar
  $ ./presto.jar --server localhost:8080 --catalog hive --schema default
  presto> select * from pokes;
```

## Issues

If you see this error below on Windows 10:
 
0075: bind: An attempt was made to access a socket in a way forbidden by its access permissions.

ERROR: for namenode  Cannot start service namenode: driver failed programming external connectivity on endpoint namenode (2f1113b225e9b87581baeb74ce7609245d6aa4a1226879396a06be097c3e37d2): Error starting userland proxy: listen tcp 0.0.0.0:50070: bind: An attempt was made to access a socket in a way forbidden by its access permissions.

ERROR: for datanode  Cannot start service datanode: driver failed programming external connectivity on endpoint datanode (138d848d8898347993e34b0455c3918f29d230ddab8f3ebbf92bbabd519c510e): Error starting userland proxy: listen tcp 0.0.0.0:50075: bind: An attempt was made to access a socket in a way forbidden by its access permissions.
ERROR: Encountered errors while bringing up the project.


Try one of the following

What port is in use:

```$ netstat -an```

What port ranges are excluded from bind:

```$ netsh interface ipv4 show excludedportrange protocol=tcp```


Use script to put the dynamic reserved range somewhere better <https://dandini.wordpress.com/2019/07/15/administered-port-exclusions-blocking-high-ports/>

~~~

rem Modify Dynamic Port Range for Development Users

netsh int ipv4 set dynamicport tcp start=20000 num=16384

netsh int ipv4 set dynamicport udp start=20000 num=16384

rem Add Registry Key

reg add HKLM\SYSTEM\CurrentControlSet\Services\hns\State /v EnableExcludedPortRange /d 0 /f


~~~



reenable
```$ bcdedit /set hypervisorlaunchtype auto```


A reboot:

```$ shutdown /r /t 0```

Delete adapter configuration:

```$ netcfg -d```



## Other stuff, most not useful

disable
```$ bcdedit /set hypervisorlaunchtype off```

Delete the unwanted ranges (<https://github.com/docker/for-win/issues/3171>)

```$ netsh interface ipv4 delete excludedportrange protocol=tcp startport=50060 numberofports=100```

You could...
Uninstall docker, disable hyper-v, reserve the port.
<https://blog.sixthimpulse.com/2019/01/docker-for-windows-port-reservations/>


Or... remove / block the dodgy Windows Update KB4074588  (<https://github.com/docker/for-win/issues/1707>)

How to block Windows Update(s) and Updated driver(s) from being installed in Windows 10.
Start –> Settings –> Update and security –> Advanced options –> View your update history –> Uninstall Updates.
Select the unwanted Update from the list and click Uninstall. *

Block a specific windows 10 update with instructions here <https://support.microsoft.com/en-us/help/3073930/how-to-temporarily-prevent-a-driver-update-from-reinstalling-in-window> or here <https://www.top-password.com/blog/block-specific-updates-in-windows-10/>




## Contributors
* Ivan Ermilov [@earthquakesan](https://github.com/earthquakesan) (maintainer)
* Yiannis Mouchakis [@gmouchakis](https://github.com/gmouchakis)
* Ke Zhu [@shawnzhu](https://github.com/shawnzhu)
