# Renew Let's Encrypt SSL cert

cd /opt/letsencrypt/
./letsencrypt-auto --config /etc/letsencrypt/cli.ini -d yanbin.me -d pic.yanbin.me \
     -d img.yanbin.me -d blog.yanbin.me -d wiki.yanbin.me -d paste.yanbin.me \
     -d zzio.org -d otog.cc --email been1986@gmail.com certonly

if [ $? -ne 0 ]
 then
        ERRORLOG=`tail /var/log/letsencrypt/letsencrypt.log`
        echo -e "The Lets Encrypt Cert has not been renewed! \n \n" $ERRORLOG | mail -s "Lets Encrypt Cert Alert" postmaster@yourdomain.com
fi

exit 0
