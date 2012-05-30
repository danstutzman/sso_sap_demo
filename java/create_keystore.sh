#!/bin/bash
SCRIPT_DIR=`dirname $0` # so this script can be run from any directory
OLD_DIR=`pwd`
ALIAS=mykey

if [ "$1" == "" ]; then
  echo 1>&2 "Please specify the name of the keystore file and exported certificate to create.  For example, $0 keystore1 verify1.der"
  exit 1
fi
KEYSTORE="$OLD_DIR/$1"
CERT_OUT="$OLD_DIR/$2"

rm -f $KEYSTORE
keytool -genkey -alias $ALIAS -keypass password -keystore $KEYSTORE -storepass password -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown" -validity 99999

# Generate a verify.der file
keytool -export -alias $ALIAS -file $CERT_OUT -keystore $KEYSTORE -storepass password

keytool -list -v -alias $ALIAS -keystore $KEYSTORE -storepass password
