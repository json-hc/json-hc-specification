# JSON-HC Specification

This is the repository for the JSON-HC Specification. If you want to contribute to this
specification, send a pull request to this repository.

The latest version is available in [json-hc.md](./json-hc.md) and will be published to <https://tools.ietf.org/html/draft-schuetze-json-hc>
once in a while.

If you want to compare json-hc to [mike kelly's](https://github.com/mikekelly/) awesome [hal](stateless.co/hal_specification.html), I created a document called [json-hc-vs-hal.md](./json-hc-vs-hal.md).

There is also an example api built with json-hc, which describes a game server api at [gameserver-json-example.md](./gameserver-json-example.md).

The official site of json-hc is <https://json-hc.org>. The maintainer and creator is [dracoblue](https://dracoblue.net).

## Tooling for the Internet Draft

The internet draft at <https://tools.ietf.org/html/draft-schuetze-json-hc> is created from the [json-hc.md](./json-hc.md) by using [mmark](https://github.com/miekg/mmark).

If you want to render the html and txt version, run:

``` console
$ ./make-internet-draft.sh json-hc
did not found mmark, launch make.sh with docker:
found mmark, launch:
2016/08/27 18:37:21 mmark: handling preface like abstract
Parsing file json-hc.xml
Created file json-hc.html
Created file json-hc.txt
```

If you don't have mmark installed, it will run a [docker](https://github.com/docker/docker) container with the script.