#!/bin/bash
set -e

### configure customization
cp -R .config $HOME && \
cp -R $HOME/.config /etc/skel 
### put under /etc/skel to turn into default config and avoid "first start"

### renaming and moving /etc/xdg/xfce4/panel/default.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml will remove the prompt and use that file to create the default panel layout.
mv -f /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml && \
rm -f $HOME/.config/xfce4/panel/default.xml 

### Install GTK theme
echo "Install Gnome Arc Theme"
#https://github.com/horst3180/arc-theme
apt-get install -y gtk2-engines-murrine gtk2-engines-pixbuf arc-theme
#wget https://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/all/arc-theme_1488477732.766ae1a-0_all.deb
#dpkg -i arc-theme_1488477732.766ae1a-0_all.deb && \
#rm -f arc-theme_1488477732.766ae1a-0_all.deb

### Install base icons
apt-get install -y gnome-icon-theme

### Install Moka Icons
echo "Install Faba Icons"
wget http://ftp.br.debian.org/debian/pool/main/f/faba-icon-theme/faba-icon-theme_4.1.2-1_all.deb && \
dpkg -i $HOME/faba-icon-theme_4.1.2-1_all.deb && \
rm -f $HOME/faba-icon-theme_4.1.2-1_all.deb && \
echo "Install Moka Icons"
wget http://ftp.br.debian.org/debian/pool/main/m/moka-icon-theme/moka-icon-theme_5.3.5-1_all.deb && \
dpkg -i $HOME/moka-icon-theme_5.3.5-1_all.deb && \
rm -f $HOME/moka-icon-theme_5.3.5-1_all.deb

### Install Dank Neon for VIM

export VIM_COLOR_URI=https://raw.githubusercontent.com/DankNeon/vim/master/colors/dank-neon.vim
export VIMRC=/headless/.vimrc
mkdir -p /headless/.vim/colors/
cd /headless/.vim/colors/
curl -O ${VIM_COLOR_URI}
tee ${VIMRC} <<-EOF
syntax on
filetype plugin indent on
colorscheme dank-neon
EOF

### Hide userland threads for HTop
echo "hide_userland_threads=1" >> /headless/.htoprc

#Generate locales
echo "generate locales" #was en_US.UTF-8 or C.UTF-8
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8