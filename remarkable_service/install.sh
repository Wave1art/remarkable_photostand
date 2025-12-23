# systemd service location
SERVICE=/etc/systemd/system/renews.service
TIMER=/etc/systemd/system/renews.timer

# stop service if running
systemctl stop renews.service || true
# install the renews binary from github releases
mkdir -p /home/root/bin
cd /home/root/bin
wget -O release.zip http://github.com/wave1art/remarkable_photostand/releases/latest/download/release.zip
unzip -o release.zip

# make the script executable
chmod +x renews.*   

# install systemd service and the associated timer
# mv renews.service ${SERVICE}
wget -O ${SERVICE} "https://raw.githubusercontent.com/Wave1art/remarkable_photostand/refs/heads/main/remarkable_service/services/${1}.service"
wget -O ${TIMER} "https://raw.githubusercontent.com/Wave1art/remarkable_photostand/refs/heads/main/remarkable_service/renews.timer"

# substitute COOLDOWN and KEYWORDS arguments
if [[ -z $COOLDOWN ]]
then
    COOLDOWN=3600
fi
sed -i "s|COOLDOWN|${COOLDOWN}|" ${SERVICE}
sed -i "s|KEYWORDS|${KEYWORDS}|" ${SERVICE}

# reload systemd and remove extra files
systemctl daemon-reload
systemctl enable --now renews.service
rm renews.x86 release.zip
