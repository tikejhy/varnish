sub vcl_pipe {
    /* Force the connection to be closed afterwards so subsequent reqs
don't use pipe */
    set bereq.http.connection = "close";
}

##### In the event of an error, show friendlier messages.

sub vcl_error {
	if (obj.status == 988) {
		set obj.http.Location = "https://" + obj.response;
		set obj.status = 302;
		return (deliver);
	}

	if ( obj.status == 750 )
	{
		if (req.http.X-GeoIP-Country == "NP") {
			set obj.http.Location = req.http.X-Forwarded-Proto + "://np.ashishnepal.com" + req.url;
		} else {
			set obj.http.Location = req.http.X-Forwarded-Proto + "://" + std.tolower(req.http.X-GeoIP-Country) + ".ashishnepal.com" + req.url;
		}
		set obj.status = 301;
		return(deliver);
	}

	if ( obj.status == 999 )
	{
		set obj.http.Content-Type = "text/plain; charset=utf-8";
		set obj.status = 200;
		set obj.response = "OK";
		synthetic server.hostname + " " + req.http.X-Forwarded-Proto + "://" + req.http.host + req.url + " OK";
		return(deliver);
	}

	# Otherwise redirect to the homepage, which will likely be in the cache.
	set obj.http.Content-Type = "text/html; charset=utf-8";
synthetic {"
<!DOCTYPE html>
<html>
<head>
<style>
<h1>Varnish error.</h1>
<p><br /><tt>Error "} + obj.status + " " + obj.response + {"</tt></p>
</div>
</body>
</html>
"};
	return (deliver);
}
