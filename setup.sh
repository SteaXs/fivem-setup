if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

install_fivem() {
    echo "========================================================="
    echo "              UPDATING & UPGRADING PACKAGES              "
    echo "========================================================="
    apt-get update -y
    apt-get upgrade -y
    clear
    echo "========================================================="
    echo "                        SETTINGS                         "
    echo "========================================================="
    echo "How do you want to name FiveM server directory?: "
    read dirname
    echo "Paste the link to linux fivem artifacts you can get it from https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/"
    read artifacts
    mkdir $dirname
    cd $dirname
    clear
    echo "========================================================="
    echo "                  INSTALLING ARTIFACTS                   "
    echo "========================================================="
    wget $artifacts
    tar -xvf fx.tar.xz
    rm -r -f fx.tar.xz
    clear
    echo "========================================================="
    echo "              INSTALLING SERVER RESOURCES                "
    echo "========================================================="
    apt install git -y
    apt install screen -y
    git clone https://github.com/citizenfx/cfx-server-data server-data
    clear
    echo "========================================================="
    echo "                INSTALLING SQL DATABASE                  "
    echo "========================================================="
    sudo apt install -y software-properties-common
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mariadb.mirror.liquidtelecom.com/repo/10.6/ubuntu focal main'
    sudo apt update
    sudo apt install -y mariadb-server mariadb-client
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    clear
    echo "========================================================="
    echo "               PLEASE CONFIGURE DATABASE                 "
    echo "========================================================="
    sudo mysql_secure_installation
    sudo apt-get install php -y
    sudo apt-get install php-{bcmath,bz2,intl,gd,mbstring,mysql,zip,fpm} -y
    sudo systemctl enable apache2.service
    sudo systemctl enable mariadb.service
    systemctl restart apache2.service
    sudo apt-get install phpmyadmin -y
    clear
    echo "========================================================="
    echo "                   SETUP IS FINISHED                     "
    echo "========================================================="
    echo ""
    echo "Type: screen -S fivem"
    scriptdir=$(dirname "$0")
    echo "Then type: cd $scriptdir/$dirname/ && ./run.sh"
}

echo "Installing dependencies that we need in order to check your OS..."
apt-get install bc -y

if [ "$OS" == "Ubuntu" ] && (( $(echo "$VER" == "20.04" |bc) )); then
    echo "Preparing the SuperUser privileges(root)"
    USER=$( whoami )
    if [ "$USER" == "root" ]; then
        install_fivem
    else
        echo "========================================================="
        echo "          YOU NEED TO BE LOGGED IN AS ROOT USER          "
        echo "========================================================="
    fi
else
    echo "========================================================="
    echo "          WE DON'T SUPPORT THIS OS FOR NOW               "
    echo "========================================================="
    echo ""
    echo "OPEN AN ISSUE INSIDE THE GITHUB IF YOU WANT US TO SUPPORT YOUR OS"
fi
