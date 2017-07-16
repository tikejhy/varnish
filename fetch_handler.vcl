sub vcl_fetch {
	set beresp.http.X-Backend = beresp.backend.name + "/" + server.identity;
	set beresp.http.X-Varnish = "2";
	if (req.url ~ "^/json/calls/$")
	{
		unset beresp.http.set-cookie;
		set beresp.ttl = 1s;
	}

	if (req.url ~ "^/res/") {
                unset beresp.http.set-cookie;
                set beresp.ttl = 86400s;
        }


        if (req.request == "GET" && req.url ~ "\.(gif|jpg|jpeg|png|ico)$") {
                set beresp.ttl = 86400s;
        }


	if(req.url ~ "/robots.txt") {
		#Robots.txt is updated rarely and should be cached for 4 days
		#Purge manually as required
		unset beresp.http.set-cookie;
		set beresp.ttl = 96h;
	}


	 if (beresp.status == 404) {
        set beresp.ttl = 0s;
        }

        if (beresp.status >= 500) {
        set beresp.ttl = 0s;
        }

}

