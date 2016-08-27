#!/bin/bash
mmark --help 2>/dev/null
if [ "$?" == "2" ]
then
    echo "found mmark, launch:"
    mmark -xml2 -page $1.md  > $1.xml && xml2rfc --text $1.xml --html $1.html
else
    echo "did not found mmark, launch make.sh with docker:"
    docker run --rm -v $(pwd):/rfc paulej/rfctools bash -c "./make-internet-draft.sh $1"
fi
