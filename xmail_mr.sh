#!/bin/bash



##############################################################################
#
# Mails an einen Patienten aus DATA VITAL mit Evolution generieren
#
# Skript erfordert Xdialog & DisplayAusgabe.sh, bitte Anleitung beachten!
#
# SP (FW), Stand August 2013 (ß)
# Änderungen:
# Auswahlfenster für Email an Patient, H-Arzt oder Ü-Arzt
# Position der Parameter ($PARAM$) in patienten$userid.txt wird vom Programm ermittelt
# Emailadresse des Patienten wird im Emailfeld u. den nächsten 4 Feldern gesucht (kann in David vorkommen)
#
##############################################################################



# Gueltige Uebergabeparameter:
#   $1=PatNr (666)
#   $2=Praxis (A)
#   $3=Arzt (C)



# ----------------------------------------------------------------------------

mailtmp=/tmp/mailtmp.tmp.$$
mailtmp1=/tmp/mailtmp1.tmp.$$

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

if [ ! -e $file ]; then
   echo "Abbruch: $file nicht gefunden oder nicht ausfuehrbar :-("
   Xdialog --title "Konfigurationsfehler"                                         \
           --ok-label "Abbruch"                                                   \
           --msgbox "$file nicht gefunden,\n\
                     Programmabbruch." 0 0
   exit 1
fi

# -----------------------------------------------------
# Parameter-Positionen ermitteln
#p-nam
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="p-nam")print i}'>$mailtmp
pnampos=`cat $mailtmp`
#pvnam
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="p-vor")print i}'>$mailtmp
pvnampos=`cat $mailtmp`
#port
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="p-ort")print i}'>$mailtmp
portpos=`cat $mailtmp`
#pmail
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="p-ema")print i}'>$mailtmp
pmailpos=`cat $mailtmp`
#pges
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="p-ges")print i}'>$mailtmp
pgespos=`cat $mailtmp`

#hnam
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="h-nam")print i}'>$mailtmp
hnampos=`cat $mailtmp`
#hort
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="h-ort")print i}'>$mailtmp
hortpos=`cat $mailtmp`
#hmail
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="h-ema")print i}'>$mailtmp
hmailpos=`cat $mailtmp`
#hges
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="h-ges")print i}'>$mailtmp
hgespos=`cat $mailtmp`

#unam
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="u-nam")print i}'>$mailtmp
unampos=`cat $mailtmp`
#uort
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="u-ort")print i}'>$mailtmp
uortpos=`cat $mailtmp`
#umail
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="u-ema")print i}'>$mailtmp
umailpos=`cat $mailtmp`
#uges
sed -n '1p' $file|sed 's/\$//g'|awk -F";" '{for(i=1;i<=NF;++i)if($i=="u-ges")print i}'>$mailtmp
ugespos=`cat $mailtmp`

# -----------------------------------------------------
# Name
# Patient
pname=`sed -n '2p' $file | awk -F";" -v POS=$pnampos '{print $POS}' | sed 's/\"//g'`
echo $pname > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
pname=`cat $mailtmp1`
# U-Arzt
uname=`sed -n '2p' $file | awk -F";" -v POS=$unampos '{print $POS}' | sed 's/\"//g'`
echo $uname > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
uname=`cat $mailtmp1`
# H-Arzt
hname=`sed -n '2p' $file | awk -F";" -v POS=$hnampos '{print $POS}' | sed 's/\"//g'`
echo $hname > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
hname=`cat $mailtmp1`
# -----------------------------------------------------


# -----------------------------------------------------
# Vorname Patient
pvname=`sed -n '2p' $file | awk -F";" -v POS=$pvnampos '{print $POS}' | sed 's/\"//g'`
echo $pvname > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
pvname=`cat $mailtmp1`
# -----------------------------------------------------


# -----------------------------------------------------
# Ort
# Patient
port=`sed -n '2p' $file | awk -F";" -v POS=$portpos '{print $POS}' | sed 's/\"//g'`
echo $port > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
port=`cat $mailtmp1`
# U-Arzt
uort=`sed -n '2p' $file | awk -F";" -v POS=$uortpos '{print $POS}' | sed 's/\"//g'`
echo $uort > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
uort=`cat $mailtmp1`
# H-Arzt
hort=`sed -n '2p' $file | awk -F";" -v POS=$hortpos '{print $POS}' | sed 's/\"//g'`
echo $hort > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
hort=`cat $mailtmp1`
# -----------------------------------------------------

# -----------------------------------------------------
# Emailadresse
# Patient
# Emailfeld u. die 4 nächsten Felder auf Mailadresse untersuchen
# wenn Emailfeld Eintrag ohne @-Zeichen enthält wir Emailadresse auf "" gesetzt (keine Adresse)
pmailpos1=`expr $pmailpos + 4`
for ((i=$pmailpos; i <= $pmailpos1; i++)) ; do
   pmail=`sed -n '2p' $file | awk -F";" -v POS=$i '{print $POS}' | sed 's/\"//g'`
   if [ `echo $pmail | grep -c "@"` -gt 0 ]; then
      break
   else
      pmail=""
   fi
done
echo $pmail > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
pmail=`cat $mailtmp1`

# U-Arzt
umail=`sed -n '2p' $file | awk -F";" -v POS=$umailpos '{print $POS}' | sed 's/\"//g'`
[ `echo $umail | grep -c "@"` -eq 0 ] && umail=""
echo $umail > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
umail=`cat $mailtmp1`

# H-Arzt
hmail=`sed -n '2p' $file | awk -F";" -v POS=$hmailpos '{print $POS}' | sed 's/\"//g'`
[ `echo $hmail | grep -c "@"` -eq 0 ] && hmail=""
echo $hmail > $mailtmp
iconv -f ISO-8859-1 -t UTF-8 $mailtmp > $mailtmp1
hmail=`cat $mailtmp1`

rm -f $mailtmp
rm -f $mailtmp1
# -----------------------------------------------------

# -----------------------------------------------------
# Mailadressen-Auswahlfenster anzeigen
Xdialog --cancel-label "Abbruch" --title "Faxnummer Auswahl" --menu "Mailadressen" 10 90 14 \
"Patient:    $pmail" "   $pname, $pvname, $port" \
"H-Arzt :    $hmail" "   $hname, $hort" \
"U-Arzt :    $umail" "   $uname, $uort" \
2> /tmp/inbox.tmp.$$
# -----------------------------------------------------

# -----------------------------------------------------
# Benutzereingaben auswerten
retval=$?

if [ $retval -gt 0 ]; then
   Xdialog --title "Abbruch" --msgbox "Abbruch durch Benutzer" 6 60
   exit 1
fi

# Selektierter Eintrag
eintrag=`cat /tmp/inbox.tmp.$$`
rm -f /tmp/inbox.tmp.$$

# wer wurde ausgewählt? (Pat, H-Arzt oder U-Arzt)
wer=`echo ${eintrag:0:1}`

# email herausfiltern
email=`echo ${eintrag:12}`

if [ -z $email ]; then
   Xdialog --title "Abbruch" --msgbox "keine Emailadresse" 6 60
   exit 1
fi
# -----------------------------------------------------

# -----------------------------------------------------
# Anrede generieren
case $wer in
   P) ges1=`sed -n '2p' $file | awk -F";" -v POS=$pgespos '{print $POS}' | sed 's/\"//g'`;
      ges=`echo ${ges1:0:1}`;
      name=$pname;;
   H) ges1=`sed -n '2p' $file | awk -F";" -v POS=$hgespos '{print $POS}' | sed 's/\"//g'`;
      # 1. Zeichen (m aus männlich oder w aus weiblich)
      ges=`echo ${ges1:0:1}`;
      name=$hname;;
   U) ges1=`sed -n '2p' $file | awk -F";" -v POS=$ugespos '{print $POS}' | sed 's/\"//g'`;
      # 1. Zeichen (m aus männlich oder w aus weiblich)
      ges=`echo ${ges1:0:1}`;
      name=$uname;;
esac
ges=`echo $ges | tr '[A-Z]' '[a-z]'`

if [ $ges = "m" ]; then
   anrede="Sehr geehrter Herr "
else
   anrede="Sehr geehrte Frau "
fi
titel=`sed -n '2p' $file | awk -F";" '{print $5}' | sed 's/\"//g'`

titel2=""
if [ -n $tiltel ]; then
   titel2="$titel "
fi
# -----------------------------------------------------

body="$anrede$titel2$name,"
echo $body
echo $email

xdg-email --body "$body" $email

# Pat.ordner aus pat_nr oeffnen:
$ablage $1 $2

exit 0
