###################################### Start of Request Handling ########################
sub vcl_recv {
	# Varnish example to serve https
	# If host is not www.ashishnepal.com and schema is not https; fwd that to https through vcl_error
        # Varnish 4 only works with synth
	if ( (req.http.host != "www.ashishnepal.com" ) && req.http.X-Forwarded-Proto !~ "(?i)https") {
		set req.http.x-Redir-Url = req.http.host + req.url;
		error 988 req.http.x-Redir-Url;
	}

	# Varnish example to serve mobile site
        #  If host is m. i.e mobile site; move to certain error code; error code will handle that.
        # Using this method you can contorl redirects transparently
	if ( req.http.host ~ "^m\.(.*?).ashishnepal.com" )
	{
		error 753 "Mobile Site Moved";
		return(error);
	}
	
	# Varnish example to block some traffic error code can be anything
         if (req.url ~ "^/some_custom_url/")
        {
        error 204 "No Content" ;
        }

	# Varnish geoip; if host is comming from different country
	if ( req.http.host == "np.ashishnepal.com" )
	{
		call geocode_and_lookup;
		if ( req.http.X-GeoIP-Country == "GB" )
		{
			error 754 "NP to GB  Redirect";
			return(error);
		}
	}

	}


	if ( req.http.host == "www.ashishnepal.com" )
	{
		if (req.http.User-Agent ~ "(?i)(ads|google|bing|msn|yandex|baidu|ro|career|)bot" ||
		    req.http.User-Agent ~ "(?i)(google)" ||
		    req.http.User-Agent ~ "(?i)(baidu|jike|symantec)spider" ||
		    req.http.User-Agent ~ "(?i)scanner" ||
		    req.http.User-Agent ~ "(?i)(web)crawler")
		{
			set req.http.X-UA-Device = "bot";
		}

		if (req.url ~ "^/logo.png")
		{
			remove req.http.Cookie;
			return(lookup);
		}

	}


	if (req.http.host ~ "^np\.ashishnepal\.com$") {
                 set req.backend = my-app;
			if(!req.backend.healthy)
                {
                        set req.backend = dr-my-app;
			if(!req.backend.healthy)
                        {
                        set req.backend = my-app;
                        }
                }
		 return(pass);

	} else {
		set req.backend = my-app;
		if(!req.backend.healthy) {
			set req.backend = dr-my-app;
			if(!req.backend.healthy)
                        {
                        set req.backend = my-app;
                        }
		}
	}

	# pipe api calls 
 	# i.e send to backend
	if (req.url ~ "^/api" && req.url !~ "^/api/facebook") {
                return(pipe);
        }

	# serve from cache by removing cookie
	if (req.url ~ "^/json/calls/$") {
		remove req.http.Cookie;
		return(lookup);
	}


	if (req.request != "GET" &&
	    req.request != "HEAD" &&
	    req.request != "PUT" &&
	    req.request != "POST" &&
	    req.request != "TRACE" &&
	    req.request != "OPTIONS" &&
	    req.request != "DELETE")
	{
		/* Non-RFC2616 or CONNECT which is weird. */
		return (pipe);
	}


	if (req.request != "GET" && req.request != "HEAD") {
		/* We only deal with GET and HEAD by default */
		return (pass);
	}

	if (req.http.Authorization || req.http.Cookie) {
		/* Not cacheable by default */
		return (pass);
	}



	if (req.http.Accept-Encoding) {
		if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
			# No point in compressing these
			remove req.http.Accept-Encoding;
		} elsif (req.http.Accept-Encoding ~ "gzip") {
			set req.http.Accept-Encoding = "gzip";
		} elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "MSIE") {
			set req.http.Accept-Encoding = "deflate";
		} else {
			# unkown algorithm
			remove req.http.Accept-Encoding;
		}
	}
 }
######################################### DO not cache Probe Thing #####################

sub vcl_deliver {
	if ( req.http.imgHost ~ "static" )
	{
		unset resp.http.Access-Control-Allow-Origin;
		set resp.http.Access-Control-Allow-Origin = "*";
	}
}

sub vcl_recv {
        # allow PURGE from localhost and 192.168.55...

        if (req.request == "PURGE") {
                if (!client.ip ~ purge) {
                        error 405 "Not allowed.";
                }
                return (lookup);
        }
}

sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 999 "Purged.";
        }
}

sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 999 "Purged.";
        }
}
######################################### End of Request Handler #########################
