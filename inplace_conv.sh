#!/bin/sh
# sed -f sedfile.sed target -i の代用品
if [ x$1 = x ]; then
  echo "usage: $0 <target> <sed-options...>"
  exit
fi
SCRIPT=$1
TARGET=$2
TMP=/tmp/INPLACE_CONV.$$
cp $TARGET $TMP
sed -f $SCRIPT $TMP > $TARGET
rm $TMP
