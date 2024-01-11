#!/bin/bash
# (C) Simon Urbanek, License: MIT

: ${PROOFSRC=~/Projects/RJ-proofs}

if [ ! -d $PROOFSRC ]; then
    echo "ERROR: cannot find incoming proofs directory, set PROOFSRC if needed"
    exit 1
fi

set -e

id=$(basename "`pwd`")
echo $id
src=$(ls -t $PROOFSRC | grep id-$id | head -n1)
if [ -z "$src" ]; then
    echo ERROR: no proof for $id found
    exit 1
fi
echo "Proof: $src"

pts=$(echo $src | sed 's:.*-::')
grep 'out for proof' DESCRIPTION | sed 's:,*$:,:'
date -r "$pts" +'  %Y-%m-%d proofed'

if [ "x$1" = x-n ]; then exit 0; fi

if [ -e DESCRIPTION -a -n "$pts" ]; then
    if ! grep 'proofed' DESCRIPTION > /dev/null; then
	echo '(adding proofed entry)'
	date -r "$pts" +'  %Y-%m-%d proofed' >> DESCRIPTION
	sed -ie 's:out for proofing$:out for proofing,:' DESCRIPTION
    fi
fi

if [ -n "$1" ]; then exit 0; fi

if [ -e .old ]; then
  mv .old old-$(stat -f '%Dc' .old)
fi

mkdir -p .old/.save

for i in DESCRIPTION correspondence history; do
    if [ -e $i ]; then
	mv $i .old/.save
    fi
done

mv * .old/
mv .old/.save/* .
rmdir .old/.save

unzip $PROOFSRC/"$src/upload.zip"

