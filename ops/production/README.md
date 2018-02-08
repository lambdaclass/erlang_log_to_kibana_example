Production script
================
The script `install.sh`  should allow you to create by just
executing it, install Elastic Search, Logstash, Kibana, and Logtrail plugin.

Considerations:

- This script uses basic authorization via [nginx], please change
  `ekl_user` and `ekl_password` for other more secure values.
- In general every `localhost` or `127.0.0.1` should be verified
  if is applicable to your use case.
- In the creation of `logstash.conf`, you need to specify the
  elasticsearch host you use.

[nginx]: https://www.nginx.com/resources/glossary/nginx/
