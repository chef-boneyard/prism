## Data Collector API

### Getting Started
```
make install
make start
```

### API

##### POST /data-collector/v0/:exchange

Publishes the request body to the specified rabbit exchange.

Example:

```
curl localhost:8585/data-collector/v0/insights \
	 -i --data 'collect me' \
	 -H 'x-data-collector-token: 93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'

HTTP/1.1 204 No Content
Date: Fri, 19 Aug 2016 18:59:16 GMT
Connection: keep-alive
```
```
curl localhost:8585/data-collector/v0/insights \
	 -i --data 'collect me'

HTTP/1.1 401 Unauthorized
Content-Type: text/plain; charset=utf-8
Content-Length: 12
Date: Fri, 19 Aug 2016 18:59:22 GMT
Connection: keep-alive

Unauthorized
```

### Test
```
make test
```
