#!/bin/bash
#echo "We will install Apache 2.4, Tomcat 8.5, Java 1.8 with this script for your Java Application, you may skip the installation as well"

if [ "$(whoami)" != 'root' ]; then
echo -e "\e[40;38;5;82mPleae login as root user \e[30;48;5;82m\e[0m: "
exit 1;
fi

echo -e "\e[40;38;5;82mPlease type your os name example centos\e[30;48;5;82m\e[0m: "
read -p "centos in lowercase, please : " osname

echo "!====================================================================================================!"
echo ""
echo ""

echo -e "\e[91mBe-Caareful before running this script ! Read each instruction before go ahead for next steps" 

echo ""
echo ""
echo "!=====================================================================================================!"

echo -e "\e[40;38;5;82mFor Installation Apache 2.4 type 1, For Instalation of Java 1.8 type 2,For Installation Apache Tomcat8 8.5 type 3, For instllation of All type 4, Or type 5 For adding domain in Apache Vhost and Tomcat\e[30;48;5;82m [1/2/3/4/5]? \e[0m: "
read q

if [[ "${q}" == "1" ]] || [[ "${q}" == "1" ]]; then

sudo yum -y install httpd

sudo systemctl enable httpd.service >/dev/null 2>&1

sudo systemctl restart httpd.servic >/dev/null 2>&1


elif [[ "${q}" == "2" ]] || [[ "${q}" == "20" ]]; then

sudo yum install java-1.8.0 -y

elif [[ "${q}" == "3" ]] || [[ "${q}" == "30" ]]; then

cd /usr/local/src/
mkdir -p /opt/tomcat
cd /opt/tomcat
wget https://github.com/backupmx-notes/Apache/raw/master/Tomcat_ZNetLive.tar.gz
tar -xvf  Tomcat_ZNetLive.tar.gz
mv Tomcat_ZNetLive/* .
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
chown -R tomcat:tomcat /opt/tomcat
chmod +x /opt/tomcat/bin/*
echo "export CATALINA_HOME=/opt/tomcat" >> ~/.bashrc
source ~/.bashrc
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT 
wget https://raw.githubusercontent.com/backupmx-notes/Apache/master/tomcat.service
cat /usr/local/src/tomcat.service > /etc/systemd/system/tomcat.service
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat 
systemctl status tomcat

elif [[ "${q}" == "4" ]] || [[ "${q}" == "40" ]]; then

sudo yum -y install httpd
sudo systemctl enable httpd.service >/dev/null 2>&1
sudo systemctl restart httpd.servic >/dev/null 2>&1
sudo yum install java-1.8.0 -y
cd /usr/local/src/
mkdir -p /opt/tomcat
cd /opt/tomcat
wget https://github.com/backupmx-notes/Apache/raw/master/Tomcat_ZNetLive.tar.gz
tar -xvf  Tomcat_ZNetLive.tar.gz
mv Tomcat_ZNetLive/* .
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
chown -R tomcat:tomcat /opt/tomcat
chmod +x /opt/tomcat/bin/*
echo "export CATALINA_HOME=/opt/tomcat" >> ~/.bashrc
source ~/.bashrc
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT 
wget https://raw.githubusercontent.com/backupmx-notes/Apache/master/tomcat.service
cat /usr/local/src/tomcat.service > /etc/systemd/system/tomcat.service
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat 
systemctl status tomcat

elif [[ "${q}" == "5" ]] || [[ "${q}" == "50" ]]; then

echo ""

fi

echo -e "\e[40;38;5;82mNew Domain (1), Subdomain (2), New Domain under Same user (3)\e[30;48;5;82m [1/2/3]? \e[0m: "

PS3='New Domain (1), Subdomain (2), New Domain under Same user (3)'
options=("Option 1" "Option 2" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "Enter the Website-name you want"
read -p "e.g. mydomain.tld (without www) : " websitename
echo "Enter the user you wanna use"
read -p "e.g. user1 : " myusername
while grep "${myusername}" /etc/passwd >/dev/null 2>&1; do
read -p "user already exist try diffirnet username : " myusername
done

useradd  $myusername
passwd $myusername

mkdir -p /home/$myusername/public_html
mkdir -p /home/$myusername/public_html/mywar
echo "New Domain" > /home/$myusername/public_html/index.html
chown $myusername:$myusername /home/$myusername/public_html/ -R
chown tomcat:tomcat /home/$myusername/public_html/mywar

find /home/$myusername -type f -exec chmod 644 {} \;
find /home/$myusername -type d -exec chmod 755 {} \;


echo -e "\e[32m!===========\e[32mNow Create Your VHost for website and install the WordPress===============================!"

echo ""
echo ""

SERVICE_="apache2"
VHOST_PATH="/etc/apache2/sites-available"
CFG_TEST="apachectl -t"
if [ "$osname" == "centos" ]; then
  SERVICE_="httpd"
  VHOST_PATH="/etc/httpd/conf.d"
  CFG_TEST="service httpd configtest"
elif [ "$osname" != "ubuntu" ]; then

echo -e "\e[40;38;5;82mSorry mate but I only support centos\e[30;48;5;82m [y/n]? \e[0m: "

echo -e "\e[40;38;5;82mBy the way, are you sure you have entered 'centos' all lowercase???\e[30;48;5;82m [y/n]? \e[0m: "
  exit 1;
fi

mkdir -p /var/log/$myusername
echo "
<VirtualHost *:80>
        ServerName $websitename
        ServerAlias www.$websitename
        DocumentRoot /home/$myusername/public_html
        ErrorLog /var/log/$myusername/error.log
        CustomLog /var/log/$myusername/access.log combined

        <Directory /home/$myusername/public_html/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                Allow from all
                Require all granted
        </Directory>

<IfModule proxy_ajp_module>
      ProxyPass "/mywar" "ajp://127.0.0.1:8009/mywar"
</IfModule>
</VirtualHost>" > $VHOST_PATH/$websitename.conf

if ! echo -e $VHOST_PATH/$websitename.conf; then
echo "Virtual host was not created"
else
echo "Virtual host created"
fi

if [ "$osname" == "ubuntu" ]; then
  echo "Enabling Virtual host..."
  sudo a2ensite $websitename.conf
fi

echo "Testing configuration"
sudo $CFG_TEST

echo -e "\e[32m!==========================\e[32mYour Apaceh Status, Make sure it running before procced futehr=============!" 

yum install unzip -y >/dev/null 2>&1
cd /home/$myusername/public_html/mywar
rm -rf sample.war sample.zip
wget https://github.com/backupmx-notes/Apache/raw/master/sample.zip
unzip sample.zip
sudo systemctl status httpd.service
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 80 -j ACCEPT
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT 
echo -e "\e[32m!==========================\e[32m===========================================================================!"
echo "!=====================================================================================================================!"
echo "websitename=znetlive.com"
echo "docBase=apsulute path of your ware folder /home/myusername/public_html"
echo "path=Your war folder name : public_htm"
echo "Please update the value as as mentioned below exact at the bottom line of the serevr.xml file before </Engine>"
echo "!=====================================================================================================================!"
echo ""
echo "Please copy the belelow context of host and add in open xml file just above </Engine> "

cd /usr/local/src/
rm -rf tomcat.host.txt
wget https://raw.githubusercontent.com/backupmx-notes/Apache/master/tomcat.host.txt >/dev/null 2>&1
cat tomcat.host.txt

vi /opt/tomcat/conf/server.xml
service tomcat stop
service tomcat start
service httpd reload

echo "All works done! You should be able to see your websitename at http://$websitename"

echo "!======================================Your Created Details as Below=====================================!"
echo ""
echo "Your Website name 			: $websitename"
echo "Username (SSH/SFTP) 			: $myusername"
echo "Password (SSH/SFTP)			: yourpassword"
echo "Java Website Document Root 	: /home/$myusername/public_html"
echo "Website Log locations 		: /var/log/$myusername/access.log"
echo "Website Log locations 		: /var/log/$myusername/error.log"
echo ""
echo "!=========================================================================================================!"
            ;;
        "Option 2")
echo "Enter the Sub-Domain you want"
read -p "e.g. new.mydomain.tld (without www) : " websitename
echo "Enter the user you wanna use"
read -p "e.g. user1 : " myusername

useradd  $myusername

cd
mkdir -p /home/$myusername/public_html/$websitename
mkdir -p /home/$myusername/public_html/$websitename/mywar
echo "Sub-Domain" > /home/$myusername/public_html/$websitename/index.html
chown $myusername:$myusername /home/$myusername/public_html/$websitename/* -R
chown tomcat:tomcat /home/$myusername/public_html/$websitename/mywar

find /home/$myusername/public_html/$websitename -type f -exec chmod 644 {} \;
find /home/$myusername/public_html/$websitename -type d -exec chmod 755 {} \;

echo -e "\e[32m!===========\e[32mNow Create Your VHost for website and install the WordPress===============================!"

echo ""
echo ""

SERVICE_="apache2"
VHOST_PATH="/etc/apache2/sites-available"
CFG_TEST="apachectl -t"
if [ "$osname" == "centos" ]; then
  SERVICE_="httpd"
  VHOST_PATH="/etc/httpd/conf.d"
  CFG_TEST="service httpd configtest"
elif [ "$osname" != "ubuntu" ]; then

echo -e "\e[40;38;5;82mSorry mate but I only support centos\e[30;48;5;82m [y/n]? \e[0m: "

echo -e "\e[40;38;5;82mBy the way, are you sure you have entered 'centos' all lowercase???\e[30;48;5;82m [y/n]? \e[0m: "
  exit 1;
fi

mkdir -p /var/log/$myusername/$websitename
echo "
<VirtualHost *:80>
        ServerName $websitename
        ServerAlias www.$websitename
        DocumentRoot /home/$myusername/public_html/$websitename
        ErrorLog /var/log/$myusername/$websitename/error.log
        CustomLog /var/log/$myusername/$websitename/access.log combined

        <Directory /home/$myusername/public_html/$websitename/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                Allow from all
                Require all granted
        </Directory>

<IfModule proxy_ajp_module>
      ProxyPass "/mywar" "ajp://127.0.0.1:8009/mywar"
</IfModule>
</VirtualHost>" > $VHOST_PATH/$websitename.conf

if ! echo -e $VHOST_PATH/$websitename.conf; then
echo "Virtual host was not created"
else
echo "Virtual host created"
fi

if [ "$osname" == "ubuntu" ]; then
  echo "Enabling Virtual host..."
  sudo a2ensite $websitename.conf
fi

echo "Testing configuration"
sudo $CFG_TEST
echo "Would you like me to restart the server [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
service $SERVICE_ restart
fi
echo -e "\e[32m!==========================\e[32mYour Apaceh Status, Make sure it running before procced futehr=============!" 

yum install unzip -y >/dev/null 2>&1
cd /home/$myusername/public_html/$websitename/mywar
rm -rf sample.war sample.zip
wget https://github.com/backupmx-notes/Apache/raw/master/sample.zip
unzip sample.zip
sudo systemctl status httpd.service
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 80 -j ACCEPT
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT 
echo -e "\e[32m!==========================\e[32m===========================================================================!"
echo "!=====================================================================================================================!"
echo "websitename=znetlive.com"
echo "docBase=apsulute path of your ware folder /home/myusername/public_html/$websitename"
echo "path=Your war folder name : /public_htm/$websitename"
echo "Please update the value as as mentioned below exact at the bottom line of the serevr.xml file before </Engine>"
echo "!=====================================================================================================================!"
echo ""
echo "Please copy the belelow context of host and add in open xml file just above </Engine> "

cd /usr/local/src/
rm -rf tomcat.host.txt
wget https://raw.githubusercontent.com/backupmx-notes/Apache/master/tomcat.host.txt >/dev/null 2>&1
cat tomcat.host.txt

vi /opt/tomcat/conf/server.xml
service tomcat stop
service tomcat start
service httpd reload

echo "All works done! You should be able to see your websitename at http://$websitename/"

echo "!======================================Your Created Details as Below=====================================!"
echo ""
echo "Your Website name 			: $websitename"
echo "Username (SSH/SFTP) 			: $myusername"
echo "Password (SSH/SFTP)			: yourpassword"
echo "Java Website Document Root 	: /home/$myusername/public_html/$websitename"
echo "Website Log locations 		: /var/log/$myusername/$websitename/access.log"
echo "Website Log locations 		: /var/log/$myusername/$websitename/error.log"
echo ""
echo "!=========================================================================================================!"
            ;;
        "Option 3")
echo "Enter the Domain-Name you want"
read -p "e.g. mydomain.tld (without www) : " websitename
echo "Enter the user you wanna use"
read -p "e.g. user1 : " myusername

useradd  $myusername

cd
mkdir -p /home/$myusername/public_html/$websitename
mkdir -p /home/$myusername/public_html/$websitename/mywar
echo "Addon-Domain" > /home/$myusername/public_html/index.html
chown $myusername:$myusername /home/$myusername/public_html/$websitename/* -R

chown tomcat:tomcat /home/$myusername/public_html/$websitename/mywar

find /home/$myusername/public_html/$websitename -type f -exec chmod 644 {} \;
find /home/$myusername/public_html/$websitename -type d -exec chmod 755 {} \;

echo -e "\e[32m!===========\e[32mNow Create Your VHost for website and install the WordPress===============================!"

echo ""
echo ""

SERVICE_="apache2"
VHOST_PATH="/etc/apache2/sites-available"
CFG_TEST="apachectl -t"
if [ "$osname" == "centos" ]; then
  SERVICE_="httpd"
  VHOST_PATH="/etc/httpd/conf.d"
  CFG_TEST="service httpd configtest"
elif [ "$osname" != "ubuntu" ]; then

echo -e "\e[40;38;5;82mSorry mate but I only support centos\e[30;48;5;82m [y/n]? \e[0m: "

echo -e "\e[40;38;5;82mBy the way, are you sure you have entered 'centos' all lowercase???\e[30;48;5;82m [y/n]? \e[0m: "
  exit 1;
fi

mkdir -p /var/log/$myusername/$websitename
echo "
<VirtualHost *:80>
        ServerName $websitename
        ServerAlias www.$websitename
        DocumentRoot /home/$myusername/public_html/$websitename
        ErrorLog /var/log/$myusername/$websitename/error.log
        CustomLog /var/log/$myusername/$websitename/access.log combined

        <Directory /home/$myusername/public_html/$websitename/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                Allow from all
                Require all granted
        </Directory>

<IfModule proxy_ajp_module>
      ProxyPass "/mywar" "ajp://127.0.0.1:8009/mywar"
</IfModule>
</VirtualHost>" > $VHOST_PATH/$websitename.conf

if ! echo -e $VHOST_PATH/$websitename.conf; then
echo "Virtual host was not created"
else
echo "Virtual host created"
fi

if [ "$osname" == "ubuntu" ]; then
  echo "Enabling Virtual host..."
  sudo a2ensite $websitename.conf
fi

echo "Testing configuration"
sudo $CFG_TEST
echo "Would you like me to restart the server [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
service $SERVICE_ restart
fi
echo -e "\e[32m!==========================\e[32mYour Apaceh Status, Make sure it running before procced futehr=============!" 

yum install unzip -y >/dev/null 2>&1
cd /home/$myusername/public_html/$websitename/mywar/
rm -rf sample.war sample.zip
wget https://github.com/backupmx-notes/Apache/raw/master/sample.zip
unzip sample.zip
sudo systemctl status httpd.service
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 80 -j ACCEPT
iptables -I INPUT -m tcp -p tcp -s 0.0.0.0/0 --dport 8080 -j ACCEPT 
echo -e "\e[32m!==========================\e[32m===========================================================================!"
echo "!=====================================================================================================================!"
echo "websitename=znetlive.com"
echo "docBase=apsulute path of your ware folder /home/myusername/public_html/$websitename"
echo "path=Your war folder name : /public_htm/$websitename"
echo "Please update the value as as mentioned below exact at the bottom line of the serevr.xml file before </Engine>"
echo "!=====================================================================================================================!"
echo ""
echo "Please copy the belelow context of host and add in open xml file just above </Engine> "

cd /usr/local/src/
rm -rf tomcat.host.txt
wget https://raw.githubusercontent.com/backupmx-notes/Apache/master/tomcat.host.txt >/dev/null 2>&1
cat tomcat.host.txt

vi /opt/tomcat/conf/server.xml
service tomcat stop
service tomcat start
service httpd reload

echo "All works done! You should be able to see your websitename at http://$websitename/"

echo "!======================================Your Created Details as Below=====================================!"
echo ""
echo "Your Website name 			: $websitename"
echo "Username (SSH/SFTP) 			: $myusername"
echo "Password (SSH/SFTP)			: yourpassword"
echo "Java Website Document Root 	: /home/$myusername/public_html/$websitename"
echo "Website Log locations 		: /var/log/$myusername/$websitename/access.log"
echo "Website Log locations 		: /var/log/$myusername/$websitename/error.log"
echo ""
echo "!=========================================================================================================!"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done