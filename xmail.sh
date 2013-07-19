#!/bin/bash



##############################################################################
#
# Mails an einen Patienten aus DATA VITAL mit Evolution generieren
#
# Skript erfordert Xdialog & DisplayAusgabe.sh, bitte Anleitung beachten!
#
# SP (FW), Stand April 2013 (ß)
#
##############################################################################



# Gueltige Uebergabeparameter:
#   $1=PatNr (666)
#   $2=Praxis (A)
#   $3=Arzt (C)



# ----------------------------------------------------------------------------



ichbins=`whoami`
ablage=/home/david/patordner.sh
export XAUTHORITY=/home/$ichbins/.Xauthority
export DISPLAY=`cat /home/$ichbins/DisplayAusgabe`
#
# Fehler ausgeben, falls keine Ausgabedatei von DisplayAusgabe.sh gefunden:
if [ ! -e /home/$ichbins/DisplayAusgabe ]; then
   echo ""
   echo "*************************************************************"
   echo "Modul nicht initialisiert, wurde DisplayAusgabe.sh gestartet?"
   echo "*************************************************************"
   echo ""
   exit 1
fi


# Terminal-IDs von $ichbins in der david.cfg auffinden:
userid="$(sed -n "/^${ichbins}/p" /home/david/david.cfg | awk '{print $10}')"
zahl=`echo $userid | awk '{print NF}'`
#
# Feststellen, ob mehrere Terminal-IDs geliefert wurden:
if [[ $zahl -gt 1 ]]; then
   echo "Abbruch: Terminalkennung '$userid' mehrfach in der david.cfg gefunden."
   Xdialog --title "Konfigurationsfehler"                                         \
           --ok-label "Abbruch"                                                   \
           --msgbox "Mehrere DV Terminalkennungen fuer User '$ichbins' gefunden,\n\
                     Programmabbruch." 0 0
   exit 1
else
   file=/home/david/trpword/$userid/patienten$userid.txt
fi


if [ ! -x $ablage ]; then
   echo "Abbruch: $ablage nicht gefunden oder nicht ausfuehrbar :-("
   Xdialog --title "Konfigurationsfehler"                                         \
           --ok-label "Abbruch"                                                   \
           --msgbox "$ablage nicht gefunden,\n\
                     Programmabbruch." 0 0
   exit 1
fi


if [[ `sed -n '2p' $file | awk -F";" '{print $4}' | sed 's/\"//g'` = M ]]; then
   anrede="Sehr geehrter Herr "
else
   anrede="Sehr geehrte Frau "
fi
titel=`sed -n '2p' $file | awk -F";" '{print $5}' | sed 's/\"//g'`

if [ -n $tiltel ]; then
   titel2="$titel "
fi
name=`sed -n '2p' $file | awk -F";" '{print $2}' | sed 's/\"//g'`

body="$anrede$titel2$name,"
adr=`sed -n '2p' $file | awk -F";" '{print $31}' | sed 's/\"//g'`


xdg-email --body "$body" $adr


# Pat.ordner aus pat_nr oeffnen:
$ablage $1 $2


exit 0