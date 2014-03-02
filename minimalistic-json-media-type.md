# Minimalistic Json Media Type

* Author: [DracoBlue](http://dracoblue.net)
* Status: I am working on this. No final version, yet!

## Basic idea

This media type is an effort to write a json media type ([RMM Level 3](http://martinfowler.com/articles/richardsonMaturityModel.html) with [HATEOAS](http://en.wikipedia.org/wiki/HATEOAS)), which is easy to implement if you OWN the server and the client (sdk)!

To understand the idea, please see the example for controlling gameservers, before you read the other sections!

## By example: Controlling Gameservers

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

## Why yet another media type?

Recently [@mca](https://github.com/mamund) posted [uber hypermedia spec](https://rawgithub.com/mamund/media-types/master/uber-hypermedia.html) and I noticed all those 'data' elements in there. This is necessary, because you don't want to mix links with data entities. In HAL/Siren there is a special `_links`/`links` object, which holds all links. In [json-ld](http://json-ld.org) there is a specific `@context` to explain what the plain json attributes **mean** in terms of linked data.

But this mixing should not a problem, if you OWN server and client. This idea should evolve to a guide, how to write APIs for clients - once it works for server+client developments.

## Writing API for YOUR Server and YOUR Client (SDK)

My general assumptions are:

- you usually (have to) know the cardinality of a specific relation when developing a client app (there is ONE self link, ONE publish link, NONE or MORE item links in a collection)
- you usually don't need a title for links
- usually you hardcode the verb for your links into your app (e.g. you DELETE to the self link and react if its not possible), so information which verb is possible is not necessary or at least not visible, yet

From ReST we take this:

* No hardcoded links in client software: We shall be able to change the host for the avatar image, so client's should not construct the avatar image url by string concatination
  * See section: Links are json properties uris on their own or suffixed with `_url`

### Links are json properties uris on their own or suffixed with `_url`

What happens if you step one big step away from the most current hypermedia specs (like HAL+CollectionJSON): why an extra object for links?

What if this HAL document:

``` json
{
  "_links": {
    "self": "http://example.org/articles/1338",
    "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
    "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
  },
  "id": 1338,
}
```

would be written as this:

``` json
{
  "id": 1338,
  "self_url": "http://example.org/articles/1338",
  "publish_url": "http://example.org/published-articles?id=1338",
  "avatar_url": "http//cdn.example.org/23051985.png"
}
```

or as this:

``` json
{
  "id": 1338,
  "self_url": "http://example.org/articles/1338",
  "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
  "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
}
```

So one cool thing what is cool about ReST and hypermedia stays in tact: no hard coded urls in the client.

You cannot set a `title` or `type` for the `rel` anymore, but nothing else is lost. If we control the client sdk, this might not be necessary.
