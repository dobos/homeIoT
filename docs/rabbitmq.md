
Install rabbitMQ from repository

    # apt-get install rabbitmq-server
	
Check rabbitmq version

    # rabbitmqctl status

Enable MQTT and management plugin
	
    # rabbitmq-plugins enable rabbitmq_mqtt
	# rabbitmq-plugins enable rabbitmq_management
	
Restart

	# /etc/init.d/rabbitmq-server restart
	
Admin web site

    http://hostname:15672/
	
Check list of vhosts and queues

	# rabbitmqctl list_vhosts
	
Create admin user

	# rabbitmqctl add_user admin ****
	# rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"	
	# rabbitmqctl set_user_tags admin administrator
	
Add a user and set permissions on / vhost

	# rabbitmqctl add_user esp <password>
    # rabbitmqctl set_permissions -p / esp "^esp-.*" ".*" ".*"	
	# rabbitmqctl set_user_tags esp administrator
	
Connect to it from node.js

* Install node.js
* Install mqtt library

    $ npm install mqtt