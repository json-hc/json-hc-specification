% title = "JSON-HC"
% abbrev = "JSON-HC"
% category = "info"
% docName = "draft-schuetze-json-hc-02"
% date = 2016-10-14T21:03:00Z
% area = "Application"
% workgroup = "Network Working Group"
% keyword = ["JSON"]
%
% [[author]]
% initials = "J."
% surname  = "Schuetze"
% fullname = "J. Schuetze"
%   [author.address]
%   email = "jans@dracoblue.de"

.# Preface

This document proposes a media type for representing JSON resources and relations with hypermedia controls.

{mainmatter}

# Introduction

JSON Hypermedia Controls (JSON-HC) is a standard which
establishes conventions for expressing hypermedia controls in JSON [@RFC7159].

The Hypermedia Controls of JSON-HC provide a way to figure out which Actions are possible with a Resource Object, what is the self URL of the Object and of which profile is the Resource Object.

# Requirements

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and OPTIONAL" in this document are to be interpreted as described in [@RFC2119].

# JSON-HC Documents

A JSON-HC Document uses the format described in [@RFC7159] and has the media type "application/vnd.hc+json".

Its root object MUST be a Resource Object.

For example:

    GET /orders/523 HTTP/1.1
    Host: example.org
    Accept: application/vnd.hc+json

    HTTP/1.1 200 OK
    Content-Type: application/vnd.hc+json

    {
      "self": "/orders/523",
      "profile": "https://example.org/rels/order",
      "https://example.org/rels/warehouse": "/warehouse/56",
      "https://example.org/rels/invoice": "/invoices/873",
      "currency": "USD",
      "status": "shipped",
      "total": 10.20
    }


Here, we have a JSON-HC document representing an order resource with the URI "/orders/523" and the profile as in [@RFC6906] defined as `"https://example.org/rels/order"`. It has "warehouse" and "invoice" links, and its own state in the form of "currency", "status", and "total" properties.

# Resource Objects

A Resource Objects represents a resource.

It has no reserved properties.

A Resource Object **MAY** contain Hypermedia Controls with either a Target URL or an Embedded Resource Object as a value.

# Hypermedia Controls

Resource Objects **MAY** contain Hypermedia Controls.

A Hypermedia Control is a property name, which is either:

* an IANA link relation name
* or a valid URI

The value of this Hypermedia Control must be an URL to the linked resource or an Embedded Resource Object.

If the value is an URL, the Resource Object needs to be fetched ondemand with an additional request.

# Embedded Resource Object

If the value of an Hypermedia Control is a JSON object, there is no additional request necessary to fetch the Resource Object for this Hypermedia Control.

# Refresh a Resource Object

If the Resource Object has a "self" Hypermedia Control, the value MUST be an URL. A request to the URL will provide the Resource Object.

# Target URL

The target URL of an Hypermedia Control is either:

* the value of an Hypermedia Control, if it is an URL
* the "self" Hypermedia Control of the Embedded Resource Object

If the Target URL is not an absolute URL, it must start with a "/" and any request to this Target URL will be preceded with the base path of the initially requested Document.

# Performing Actions

The Target URL of an Hypermedia Control can be used as target for HTTP requests.

# Retrieve available HTTP methods

JSON-HC does not provide an own way to define, which HTTP methods a JSON-HC Target URL may accept.

If a server needs to list the possible HTTP methods available for a resource, it **SHOULD** provide an Allow Header [@RFC7231].

    OPTIONS /cancelation/123 HTTP/1.1

    HTTP/1.1 204 No Content
    Allow: POST, OPTIONS

If the resource was requested with an unsupported method, the server should reply with *405 Method not Allowed* HTTP Status Code.

# Profile of a Resource Object

If the Resource Object has a profile Hypermedia Control, a client can use this to figure out of which kind the Resource Object is.

# Examples

The following order resource has a self Hypermedia Control as defined by IANA Link Relations and a custom cancel Hypermedia Control.

    GET /orders/523 HTTP/1.1
    Host: example.org
    Accept: application/vnd.hc+json

    HTTP/1.1 200 OK
    Content-Type: application/vnd.hc+json

    {
      "self": "/orders/523",
      "profile": "https://example.org/rels/order",
      "https://example.org/rels/cancel": "/cancelation/873",
      "currency": "USD",
      "status": "created",
      "total": 10.20
    }

If the client wants to cancel the order, it does a POST HTTP Request to the cancel Hypermedia Control.

    POST /cancelation/123 HTTP/1.1

    HTTP/1.1 204 No Content

If POST would be not available, the server responds with:

    HTTP/1.1 405 Method Not Allowed
    Allow: DELETE

A client might decide to use DELETE method instead of the hard coded POST method instead.

# Security Considerations

Since JSON-HC documents are JSON documents, they inherit all security considerations of RFC 7159 [@RFC7159].

The linking part of the JSON-HC media type is not known to introduce any new security issues not already discussed in
RFC 5988 [@RFC5988] for generic use of web linking mechanisms.

The JSON-HC documents follow the Web Origin Concept of RFC 6454 [@RFC6454] and by default only allow access to documents
of the same origin. Network resources can also opt into letting other origins read their information, for example, using
Cross-Origin Resource Sharing [@CORS].

{{json-hc.bib.xml}}

{backmatter}
