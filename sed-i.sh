#!/bin/sh
# sed -f sedfile.sed target -i の代用品
if [ x$1 = x ]; then
  echo "usage: $0 <sed-script> <target>"
  exit
fi
TARGET=$2
SCRIPT=$1
TMP=/tmp/INPLACE_CONV.$$
cp $TARGET $TMP
sed -f $SCRIPT $TMP > $TARGET
rm $TMP
