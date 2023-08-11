#!/usr/bin/env bash

VERSION="1.3.7"

# Download
if [ ! -e Obsidian-${VERSION}.AppImage ] ; then
  echo "> Downloading Obsidian AppImage"
  RESPONSE=$(curl -LO -w '%{response_code}' https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/Obsidian-${VERSION}.AppImage)
  if [ $? -gt 0 ] ; then
    echo "> Could not download Obsidian from https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/Obsidian-${VERSION}.AppImage"
    exit 1
  fi
  if [ $RESPONSE != "200" ] ; then
    echo "> Could not download Obsidian from https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/Obsidian-${VERSION}.AppImage"
    exit 1
  fi
  chmod +x Obsidian-${VERSION}.AppImage
fi

# Create the desktop file
rm -f obsidian.desktop
cp obsidian.desktop.template obsidian.desktop
sed -i "s/OBSIDIAN_VERSION/${VERSION}/g" obsidian.desktop

# Extract obsidian.png icon
./Obsidian-${VERSION}.AppImage --appimage-extract >/dev/null

for iconsize in 16x16 32x32 48x48 64x64 128x128 256x256 512x512 ; do
  filename="/usr/share/icons/hicolor/${iconsize}/apps/obsidian.png"
  dname=$(dirname $filename)
  if [ ! -e ${dname} ] ; then
    sudo mkdir -p ${dname}
  fi
  sudo cp squashfs-root${filename} ${filename}
  sudo chcon -u system_u -r object_r -t usr_t ${filename}
done

rm -rf squashfs-root

if [ ! -e /opt/obsidian ] ; then
  sudo mkdir -p /opt/obsidian
  sudo chown root:root /opt/obsidian
  sudo chmod 0755 /opt/obsidian
fi
sudo cp ./Obsidian-${VERSION}.AppImage /opt/obsidian/Obsidian.AppImage
sudo chown root:root /opt/obsidian/Obsidian.AppImage
sudo chmod 0755 /opt/obsidian/Obsidian.AppImage
sudo chcon -u system_u -r object_r -t bin_t /opt/obsidian/Obsidian.AppImage

sudo cp obsidian.desktop /usr/share/applications/obsidian.desktop
sudo chown root:root /usr/share/applications/obsidian.desktop
sudo chmod 0644 /usr/share/applications/obsidian.desktop
sudo chcon -u system_u -r object_r -t usr_t /usr/share/applications/obsidian.desktop

sudo gtk-update-icon-cache
xdg-desktop-menu forceupdate

