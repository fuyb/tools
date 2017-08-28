#!/bin/bash
# Renew Let's Encrypt SSL cert
set -x

DOMAIN="ssl.example.com"
DOMAIN2="ssl.example.com"
NAME="example"
PASSWD="password"
LETSENCRYPT_PATH="/etc/letsencrypt/live/$DOMAIN"

cd /opt/letsencrypt/
./letsencrypt-auto certonly \
     --config /etc/letsencrypt/webroot.ini \
     -d $DOMAIN \
     -d $DOMAIN2

openssl pkcs12 -export \
  -in $LETSENCRYPT_PATH/fullchain.pem \
  -inkey $LETSENCRYPT_PATH/privkey.pem \
  -out $LETSENCRYPT_PATH/fullchain_and_key.p12 \
  -name $NAME -password pass:$PASSWD

keytool -delete \
  -alias $NAME \
  -keystore $LETSENCRYPT_PATH/keystore.jks \
  -storepass $PASSWD \
  -noprompt

keytool -importkeystore \
  -deststorepass $PASSWD \
  -destkeypass $PASSWD \
  -destkeystore $LETSENCRYPT_PATH/keystore.jks \
  -srckeystore $LETSENCRYPT_PATH/fullchain_and_key.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass $PASSWD \
  -alias $NAME

keytool -export -alias $NAME \
  -file $LETSENCRYPT_PATH/$NAME.cer \
  -keystore $LETSENCRYPT_PATH/keystore.jks \
  -storepass $PASSWD -noprompt

keytool -delete \
  -alias $NAME \
  -keystore $LETSENCRYPT_PATH/truststore.jks \
  -storepass $PASSWD \
  -noprompt

keytool -import -trustcacerts -alias $NAME \
  -file $LETSENCRYPT_PATH/$NAME.cer \
  -keystore $LETSENCRYPT_PATH/truststore.jks \
  -storepass $PASSWD -noprompt

if [ $? -ne 0 ]
 then
        ERRORLOG=`tail /var/log/letsencrypt/letsencrypt.log`
        echo -e "The Lets Encrypt Cert has not been renewed! \n \n" $ERRORLOG | \
               mail -s "Lets Encrypt Cert Alert" been1986@gmail.com
else 
        systemctl restart red5pro
fi

exit 0
