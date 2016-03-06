var mqtt = require("mqtt")

var client = mqtt.connect("mqtt://192.168.0.117:1883",
	{
		username: "admin",
		password: "nyuszikju"
	});
	
client.on("connect", function() {
	console.log("connected");	
	client.subscribe("/home/env/temp", 0, function(err, granted)
	{
		console.log("granted: " + granted.qos);
		console.log("err: " + err);
	});
	
	//client.publish("test", "message");
});
	
client.on("message", function(topic, message) {
	console.log(message.toString());
});