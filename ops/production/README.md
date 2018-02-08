Production script
================
The script `install.sh`  should allow you to create by just
executing it, install Elastic Search, Logstash, Kivana, and Logtrail plugin.

## Test it
You can test it opening a docker

~~~
$ docker run --rm --name erlang_log_kibana \
    -p "9200:9200" -p "5601:5601" -p "9125:9125/udp" -p "19090:19090" \
    -it openjdk
~~~

Then in other terminal

~~~
$ cd production
$ docker cp install.sh erlang_log_kibana:/tmp/install.sh
~~~

Finally in the docker machine:

~~~
$ cd /tmp
$ sh install.sh
~~~

And finally you can see kibana working at `http://localhost:19090`.
