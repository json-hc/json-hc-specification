# Example "Controlling Gameservers"

* Author: [DracoBlue](http://dracoblue.net)
* Status: I am working on this. No final version, yet!

Let's say we own a game hosting service, and want to start, stop, backup game servers. Additionally it should be possible to set server password and public/private state of the server.

### Server

#### `GET /`

``` json
{
  "http://example.org/rels/servers": "http://example.org/servers"
}
```

#### `GET /servers`

Not expanded:

``` json
{
   "next_link": "http://example.org/servers?page=2",
   "http://example.org/rels/server": [
      "http://example.org/servers/1338"
   ]
}
```

OR expanded:

``` json
{
   "next_link": "http://example.org/servers?page=2",
   "http://example.org/rels/server": [
      {
        "self_link": "http://example.org/servers/1338",
        "name": "My Gameserver",
        "is_running": true,
				"http://example.org/rels/stop": "http://example.org/stopped-servers?id=1338"
      }
   ]
}
```

#### `GET /servers/1338`

``` json
{
  "self_link": "http://example.org/servers/1338",
  "name": "My Gameserver",
  "is_running": false,
	"http://example.org/rels/start": "http://example.org/started-servers?id=1338"
}
```

#### `POST /started-servers?id=1338`

Does reply with headers:

```
HTTP/1.1 201 Created
Location: http://example.org/servers/1338/log/1573923
```

in case of success.

Otherwise (with 400 status code):

``` json
{
  "message": "Server is already running!"
}
```

#### `GET /servers/1338/log/1573923`

``` json
{
  "self_link": "http://example.org/servers/1338/log/1573923",
  "message": "Server started",
  "date": "2000-01-01T13:37:55Z"
}
```

### Client (SDK) Use-Cases

#### `getServers(): Server[]`

1. GET `/`
2. GET link: `http://example.org/rels/servers`

Return all `http://example.org/rels/server` links as `Server` objects.

### `getServerById(id): Server`

1. GET `/`
2. GET link: `http://example.org/rels/servers` with GET parameter `id=1338` (if id is 1338).

If there is one `http://example.org/rels/server` link, then return it as `Server` object. If it's not available, throw an exception that the server is not found.

### `isServerRunning(id): boolean`

1. GET `/`
2. GET link: `http://example.org/rels/servers` with GET parameter `id=1338` (if id is 1338).
3. GET first link: `http://example.org/rels/server`

If `is_running` property is `true`, return true. Return `false` otherwise. If the server link does not exist, throw an exception.

### `startServer(id): LogEntry`

1. GET `/`
2. GET link: `http://example.org/rels/servers` with GET parameter `id=1338` (if id is 1338).
3. GET first link: `http://example.org/rels/server`
4. POST link: `http://example.org/rels/start`

If there is no `http://example.org/rels/start` link, throw an exception, which states that the server is already started.

The response is a 201 redirect to a log entry and will be returned as LogEntry.

### `stopServer(id): LogEntry`

1. GET `/`
2. GET link: `http://example.org/rels/servers` with GET parameter `id=1338` (if id is 1338).
3. GET first link: `http://example.org/rels/server`
4. POST link: `http://example.org/rels/stop`

If there is no `http://example.org/rels/stop` link, throw an exception, which states that the server is already stopped.

The response is a 201 redirect to a log entry and will be returned as LogEntry.
