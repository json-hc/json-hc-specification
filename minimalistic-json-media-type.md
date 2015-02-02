# Minimalistic Json Media Type

* Author: [DracoBlue](http://dracoblue.net)
* Status: I am working on this. No final version, yet!

## Basic idea

This media type is an effort to write a json media type ([RMM Level 3](http://martinfowler.com/articles/richardsonMaturityModel.html) with [HATEOAS](http://en.wikipedia.org/wiki/HATEOAS)), which is easy to implement if you OWN the server and the client (sdk)!

To understand the idea, please see the example for controlling gameservers in [gameserver-json-example.md](gameserver-json-example.md), before you read the other sections!

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
  * See section: Links are json properties uris on their own or suffixed with `_link`

### Links are json properties uris on their own or suffixed with `_link`

What happens if you step one big step away from the most current hypermedia specs (like HAL+CollectionJSON): why an extra object for links?

What if this HAL document:

``` json
{
  "_links": {
    "self": "http://example.org/articles/1338",
    "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
    "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
  },
  "id": 1338
}
```

would be written as this:

``` json
{
  "id": 1338,
  "self_link": "http://example.org/articles/1338",
  "publish_link": "http://example.org/published-articles?id=1338",
  "avatar_link": "http//cdn.example.org/23051985.png"
}
```

or as this:

``` json
{
  "id": 1338,
  "self_link": "http://example.org/articles/1338",
  "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
  "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
}
```

So one cool thing what is cool about ReST and hypermedia stays in tact: no hard coded urls in the client.

You cannot set a `title` or `type` for the `rel` anymore, but nothing else is lost. If we control the client sdk, this might not be necessary.

### If a link may appear multiple times, it is always an array

The HAL document:

``` json
{
  "_links": {
    "self": "http://example.org/latest-articles",
    "http://example.org/rels/article": [
      "http://example.org/articles/1338",
      "http://example.org/articles/1336",
      "http://example.org/articles/1333"
    ]
  }
}
```

would be written as this:

``` json
{
  "self_link": "http://example.org/latest-articles",
  "http://example.org/rels/article": [
    "http://example.org/articles/1338",
    "http://example.org/articles/1336",
    "http://example.org/articles/1333"
  ]
}
```

So if we have no articles:

``` json
{
  "self_link": "http://example.org/latest-articles",
  "http://example.org/rels/article": []
}
```

### Embedded resources are links, which are resolved

If we want to embed a ressource in HAL, we have to do it in this way:

``` json
{
  "_links": {
    "self": "http://example.org/latest-articles",
    "http://example.org/rels/article": [
      "http://example.org/articles/1338",
      "http://example.org/articles/1336",
      "http://example.org/articles/1333"
    ]
  },
  "_embedded": {
    "http://example.org/rels/article": [
      {
        "_links": {
          "self": "http://example.org/articles/1338",
          "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
          "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
        },
        "id": 1338
      }
    ]
  }
}
```

But with this media type, a link can be included by including the response:

``` json
{
  "self_link": "http://example.org/latest-articles",
  "http://example.org/rels/article": [
    {
      "id": 1338,
      "self_link": "http://example.org/articles/1338",
      "http://example.org/rels/publish": "http://example.org/published-articles?id=1338",
      "http://example.org/rels/avatar": "http//cdn.example.org/23051985.png"
    },
    "http://example.org/articles/1336",
    "http://example.org/articles/1333"
  ]
}
```
