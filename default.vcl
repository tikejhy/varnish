################### Define Backend Servers ##########################################

backend web01 {
	.host = "10.10.10.1;
	.probe = {
		.url = "/";
		.timeout = 1 s;
		.interval = 3s;
		.window = 5;
		.threshold = 3;
	}
}

backend web02 {
	.host = "10.10.10.2";
	.probe = {
		.url = "/";
		.timeout = 1 s;
		.interval = 3s;
		.window = 5;
		.threshold = 3;
	}
}

backend web03 {
	.host = "10.10.10.3";
	.probe = {
		.url = "/";
		.timeout = 2 s;
		.interval = 3s;
		.window = 5;
		.threshold = 3;
	}
}

backend web04 {
	.host = "10.10.10.4";
	.probe = {
		.url = "/";
		.timeout = 2 s;
		.interval = 3s;
		.window = 5;
		.threshold = 3;
	}
}

director my-app round-robin {
	{ .backend = web01; }
        { .backend = web02; }
}

director dr-my-app round-robin {
	{ .backend = web03; }
	{ .backend = web04; }

acl purge {
        "localhost";
        "62.232.107.37"/24;
}

import timeutils;
import cookie;

include "/etc/varnish/geoip_plugin.vcl";
include "/etc/varnish/recvHandler.vcl";
include "/etc/varnish/fetchHandler.vcl";
include "/etc/varnish/security/main.vcl";
include "/etc/varnish/errorCode.vcl";
include "/etc/varnish/banUserAgent.vcl";
