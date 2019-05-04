## **H1 - Hello Salt!** Master-slave, pull -arkkitehtuuri.

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Asenna Salt Master ja Slave pull-arkkitehtuurilla (eli master on server). Voit laittaa herran ja orjan myös samalle koneelle. Kokeile suorittamalla salt:illa komentoja etänä.

2. Kokeile jotain [Laineen esimerkistä](https://github.com/joonaleppalahti/CCM/tree/master/salt/srv/salt) lainattua tilaa tai tee jostain tilasta oma muunnelma. Muista testata lopputuloksen toimivuus. Huomaa, että varastossa on myös keskeneräisiä esimerkkejä, kuten Battlenet-asennus Windowsille.

3. Kerää laitetietoja koneilta saltin grains-mekanismilla.

4. Oikeaa elämää. Säädä Saltilla jotain pientä, mutta oikeaa esimerkiksi omalta koneeltasi tai omalta virtuaalipalvelimelta. (Kannattaa kokeilla Saltia oikeassa elämässä, mutta jos se ei onnistu, rakenna jotain oikeaa konettasi vastaava virtuaaliympäristö ja tee asetus siinä).

---

#### 1. Masterin ja minionin asennukset + komentojen suorittamista

Käytössä on virtuaalikoneelle (Hyper-V) juuri asennettu ja päivitetty Ubuntu 18.04.2 LTS x64 (isäntäkoneella Windows Embedded 8.1 Industry Pro x64), joten aloitan laittamalla SSH-asetukset ja palomuurin kuntoon. 
Kun olen saanut virtuaalikoneeseen SSH-yhteyden läppäriltäni, jatkan asentamalla Saltin:

>sudo apt-add-repository universe\
>sudo apt-get update\
>sudo apt-get install salt-master\
>sudo apt-get install salt-minion 

Salt käyttää portteja 4505 ja 4506, mutta tällä kertaa master ja minion ovat samalla koneella, joten en avaa niitä palomuurista.
Tarkistan statukset asennuksen jälkeen:

![screenshot-1](/assignments/H1/images/screenshot-1.png)

Master ja minion ovat molemmat käynnissä.
Laitetaan ne juttelemaan toisilleen muokkaamalla minionin asetuksia:

>sudo nano /etc/salt/minion

![screenshot-2](/assignments/H1/images/screenshot-2.png)

Tallennetaan tiedosto ylläolevien asetuksien jälkeen ja käynnistetään minioni uudestaan:

>sudo systemctl restart salt-minion

Katsotaan, mitä kävi:

![screenshot-3](/assignments/H1/images/screenshot-3.png)

Jaha, Salt ei salli tabulaattorin käyttöä asetuksissa. Poistetaan ne:

>sudo sed -i 's/\t/ /g' /etc/salt/minion 

Uusi yritys:

![screenshot-5](/assignments/H1/images/screenshot-5.png)

Kaikki ok. Laitetaan master hyväksymään minionin avain:

![screenshot-6](/assignments/H1/images/screenshot-6.png)

![screenshot-7](/assignments/H1/images/screenshot-7.png)

Ajetaan pari komentoa testiksi:

![screenshot-8](/assignments/H1/images/screenshot-8.png)

![screenshot-9](/assignments/H1/images/screenshot-9.png)

Toimii.

---

#### 2. Kokeile esimerkkiä

Yritän ottaa mallia [Joona Leppälahden](https://github.com/joonaleppalahti/CCM/blob/master/salt/srv/salt/firewall.sls) firewall statuksesta, mutta käyttämällä pelkkää iptablesia.
Luodaan statukselle hakemisto ja tiedosto, joka pitää sisällään halutut iptables-säännöt:

![screenshot-10](/assignments/H1/images/screenshot-10.png)

![screenshot-11](/assignments/H1/images/screenshot-11.png)

IPv6 ei ole käytössä, joten tämä riittää.
Nollataan olemassaolevat säännöt ja sallitaan kaikki sisääntuleva liikenne (SSH on käytössä, joten laitan komennot peräkkäin, että en lukitsisi itseäni ulos):

![screenshot-12](/assignments/H1/images/screenshot-12.png)

Luodaan itse status:

![screenshot-13](/assignments/H1/images/screenshot-13.png)

Kokeillaan:

![screenshot-14](/assignments/H1/images/screenshot-14.png)

Hups, iptables.rules on väärässä hakemistossa. Korjataan asia:

![screenshot-15](/assignments/H1/images/screenshot-15.png)

Uusi yritys:

![screenshot-16](/assignments/H1/images/screenshot-16.png)

Tiedostoa ei löydy? Löytyypäs:

![screenshot-17](/assignments/H1/images/screenshot-17.png)

En keksi ratkaisua :(
Moving on.

---

#### 3. Tietojen kerääminen grainsilla

Kerätään tietoja minionista Saltin grains-toiminnon avulla:

>sudo salt 'ubuserver' grains.items

Tietoja tulee rivikaupalla. Tallennetaan ne tiedostoon ja lasketaan samalla rivien määrä:

![screenshot-18](/assignments/H1/images/screenshot-18.png)

Tässä esimerkki ensimmäisestä less-ruudullisesta:

![screenshot-19](/assignments/H1/images/screenshot-19.png)

Kokeillaan vielä jonkin tietyn tiedon pyytämistä minionilta:

![screenshot-20](/assignments/H1/images/screenshot-20.png)

Kaikki grains-komennot saa listattua seuraavasti:

>sudo salt '*' grains.ls

---

#### 4. Omaa kokeilua

Kokeilen tehdä pilvipalvelimestani minionin ja siirtää palvelimen asetustiedostoja masterille myöhempää käyttöä varten. Todellisuudessa tämä olisi järkevämpi tehdä esim. Gitin avulla, mutta kokeillaan kuitenkin.
Palvelimella on käyttöjärjestelmänä Arch Linuxiin pohjautuva Parabola.
Asennan Saltin:

![screenshot-21](/assignments/H1/images/screenshot-21.png)

~~Avaan tarvittavat portit pilvipalvelimen palomuuriin:~~

![screenshot-22](/assignments/H1/images/screenshot-22.png)

~~Otan uuden säännön käyttöön:~~

~~>sudo iptables-restore < /etc/iptables/iptables.rules.wg~~

**Edit:** Tajusin jälkeenpäin, että tämä oli täysin turhaa. Kaikki data koneiden välillä kulkee jo-sallitun Wireguard-tunnelin kautta (_-A INPUT -i wg0 -j ACCEPT_).

Muokkaan palvelimen salt-minionin osoittamaan masteria kohti ja käynnistän sen.
Vilkaisen, näkeekö masteri sitä:

![screenshot-23](/assignments/H1/images/screenshot-23.png)

Kyllä, uusi avain oli odottamassa.
Jotta tiedostojen siirto minionilta masterille cp-moduulilla olisi mahdollista, täytyy ensin muokata masterin asetuksia:

>sudo nano /etc/salt/master

![screenshot-24](/assignments/H1/images/screenshot-24.png)

>sudo systemctl restart salt-master

Kokeillaan hakea minionilta tiedostoja:

![screenshot-25](/assignments/H1/images/screenshot-25.png)

Näyttää toimivan. Tarkistetaan vielä, saapuivatko tiedostot:

![screenshot-26](/assignments/H1/images/screenshot-26.png)

Siellähän ne.
