#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

VERSION="102.3.0esr"
echo "Install Firefox $VERSION"

function disableUpdate(){
    ff_def="$1/browser/defaults/profile"
    mkdir -p $ff_def
    echo <<EOF_FF
user_pref("app.update.auto", false);
user_pref("app.update.enabled", false);
user_pref("app.update.lastUpdateTime.addon-background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.background-update-timer", 1182011519);
user_pref("app.update.lastUpdateTime.blocklist-background-update-timer", 1182010203);
user_pref("app.update.lastUpdateTime.microsummary-generator-update-timer", 1222586145);
user_pref("app.update.lastUpdateTime.search-engine-update-timer", 1182010203);
EOF_FF
    > $ff_def/user.js
}

function instFF() {
    if [ ! "${1:0:1}" == "" ]; then
        FF_VERS=$1
        if [ ! "${2:0:1}" == "" ]; then
            FF_INST=$2
            echo "download Firefox $FF_VERS and install it to '$FF_INST'."
            mkdir -p "$FF_INST"
            FF_URL=http://releases.mozilla.org/pub/firefox/releases/$FF_VERS/linux-x86_64/en-US/firefox-$FF_VERS.tar.bz2
            echo "FF_URL: $FF_URL"
            wget -qO- $FF_URL | tar xvj --strip 1 -C $FF_INST/
            ln -s "$FF_INST/firefox" /usr/bin/firefox
            disableUpdate $FF_INST
            exit $?
        fi
    fi
    echo "function parameter are not set correctly please call it like 'instFF [version] [install path]'"
    exit -1
}

instFF "$VERSION" '/usr/lib/firefox'


cat <<EOF >> /headless/Desktop/firefox.desktop 
[Desktop Entry]
Name=Firefox ESR
Name[bg]=Firefox ESR
Name[ca]=Firefox ESR
Name[cs]=Firefox ESR
Name[el]=Firefox ESR
Name[es]=Firefox ESR
Name[fa]=Firefox ESR
Name[fi]=Firefox ESR
Name[fr]=Firefox ESR
Name[hu]=Firefox ESR
Name[it]=Firefox ESR
Name[ja]=Firefox ESR
Name[ko]=Firefox ESR
Name[nb]=Firefox ESR
Name[nl]=Firefox ESR
Name[nn]=Firefox ESR
Name[no]=Firefox ESR
Name[pl]=Firefox ESR
Name[pt]=Firefox ESR
Name[pt_BR]=Firefox ESR
Name[ru]=Firefox ESR
Name[sk]=Firefox ESR
Name[sv]=Firefox ESR
Comment=Browse the World Wide Web
Comment[bg]=Сърфиране в Мрежата
Comment[ca]=Navegueu per el web
Comment[cs]=Prohlížení stránek World Wide Webu
Comment[de]=Im Internet surfen
Comment[el]=Περιηγηθείτε στον παγκόσμιο ιστό
Comment[es]=Navegue por la web
Comment[fa]=صفحات شبکه جهانی اینترنت را مرور نمایید
Comment[fi]=Selaa Internetin WWW-sivuja
Comment[fr]=Navigue sur Internet
Comment[hu]=A világháló böngészése
Comment[it]=Esplora il web
Comment[ja]=ウェブを閲覧します
Comment[ko]=웹을 돌아 다닙니다
Comment[nb]=Surf på nettet
Comment[nl]=Verken het internet
Comment[nn]=Surf på nettet
Comment[no]=Surf på nettet
Comment[pl]=Przeglądanie stron WWW 
Comment[pt]=Navegue na Internet
Comment[pt_BR]=Navegue na Internet
Comment[ru]=Обозреватель Всемирной Паутины
Comment[sk]=Prehliadanie internetu
Comment[sv]=Surfa på webben
GenericName=Web Browser
GenericName[bg]=Интернет браузър
GenericName[ca]=Navegador web
GenericName[cs]=Webový prohlížeč
GenericName[de]=Webbrowser
GenericName[el]=Περιηγητής ιστού
GenericName[es]=Navegador web
GenericName[fa]=مرورگر اینترنتی
GenericName[fi]=WWW-selain
GenericName[fr]=Navigateur Web
GenericName[hu]=Webböngésző
GenericName[it]=Browser Web
GenericName[ja]=ウェブ・ブラウザ
GenericName[ko]=웹 브라우저
GenericName[nb]=Nettleser
GenericName[nl]=Webbrowser
GenericName[nn]=Nettlesar
GenericName[no]=Nettleser
GenericName[pl]=Przeglądarka WWW
GenericName[pt]=Navegador Web
GenericName[pt_BR]=Navegador Web
GenericName[ru]=Интернет-браузер
GenericName[sk]=Internetový prehliadač
GenericName[sv]=Webbläsare
X-GNOME-FullName=Firefox ESR Web Browser
X-GNOME-FullName[bg]=Интернет браузър (Firefox ESR)
X-GNOME-FullName[ca]=Navegador web Firefox ESR
X-GNOME-FullName[cs]=Firefox ESR Webový prohlížeč
X-GNOME-FullName[el]=Περιηγήτης Ιστού Firefox ESR
X-GNOME-FullName[es]=Navegador web Firefox ESR
X-GNOME-FullName[fa]=مرورگر اینترنتی Firefox ESR
X-GNOME-FullName[fi]=Firefox ESR-selain
X-GNOME-FullName[fr]=Navigateur Web Firefox ESR
X-GNOME-FullName[hu]=Firefox ESR webböngésző
X-GNOME-FullName[it]=Firefox ESR Browser Web
X-GNOME-FullName[ja]=Firefox ESR ウェブ・ブラウザ
X-GNOME-FullName[ko]=Firefox ESR 웹 브라우저
X-GNOME-FullName[nb]=Firefox ESR Nettleser
X-GNOME-FullName[nl]=Firefox ESR webbrowser
X-GNOME-FullName[nn]=Firefox ESR Nettlesar
X-GNOME-FullName[no]=Firefox ESR Nettleser
X-GNOME-FullName[pl]=Przeglądarka WWW Firefox ESR
X-GNOME-FullName[pt]=Firefox ESR Navegador Web
X-GNOME-FullName[pt_BR]=Navegador Web Firefox ESR
X-GNOME-FullName[ru]=Интернет-браузер Firefox ESR
X-GNOME-FullName[sk]=Internetový prehliadač Firefox ESR
X-GNOME-FullName[sv]=Webbläsaren Firefox ESR
Exec=/usr/lib/firefox-esr/firefox-esr %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=firefox-esr
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox-esr
StartupNotify=true
EOF
