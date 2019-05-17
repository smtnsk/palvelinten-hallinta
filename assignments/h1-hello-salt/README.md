## H1 - Hello Salt! Master-slave, pull -arkkitehtuuri.

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. [Asenna Salt Master ja Slave pull-arkkitehtuurilla (eli master on server). Voit laittaa herran ja orjan myös samalle koneelle. Kokeile suorittamalla salt:illa komentoja etänä.](#tehtava1)

2. [Kokeile jotain](#tehtava2) [Laineen esimerkistä](https://github.com/joonaleppalahti/CCM/tree/master/salt/srv/salt) [lainattua tilaa tai tee jostain tilasta oma muunnelma. Muista testata lopputuloksen toimivuus. Huomaa, että varastossa on myös keskeneräisiä esimerkkejä, kuten Battlenet-asennus Windowsille.](#tehtava2)

3. [Kerää laitetietoja koneilta saltin grains-mekanismilla.](#tehtava3)

4. [Oikeaa elämää. Säädä Saltilla jotain pientä, mutta oikeaa esimerkiksi omalta koneeltasi tai omalta virtuaalipalvelimelta. (Kannattaa kokeilla Saltia oikeassa elämässä, mutta jos se ei onnistu, rakenna jotain oikeaa konettasi vastaava virtuaaliympäristö ja tee asetus siinä).](#tehtava4)

---

#### <a id="tehtava1">1. Masterin ja minionin asennukset + komentojen suorittamista</a>

Käytössä on virtuaalikoneelle (Hyper-V) juuri asennettu ja päivitetty Ubuntu 18.04.2 LTS x64 (isäntäkoneella Windows Embedded 8.1 Industry Pro x64), joten aloitan laittamalla SSH-asetukset ja palomuurin kuntoon. 
Kun olen saanut virtuaalikoneeseen SSH-yhteyden läppäriltäni, jatkan asentamalla Saltin:

>sudo apt-add-repository universe\
>sudo apt-get update\
>sudo apt-get install salt-master\
>sudo apt-get install salt-minion 

Salt käyttää portteja 4505 ja 4506, mutta tällä kertaa master ja minion ovat samalla koneella, joten en avaa niitä palomuurista.
Tarkistan statukset asennuksen jälkeen:

![screenshot-1](/assignments/h1-hello-salt/screenshots/screenshot-1.png)

Master ja minion ovat molemmat käynnissä.
Laitetaan ne juttelemaan toisilleen muokkaamalla minionin asetuksia:

>sudo nano /etc/salt/minion

![screenshot-2](/assignments/h1-hello-salt/screenshots/screenshot-2.png)

Tallennetaan tiedosto ylläolevien asetuksien jälkeen ja käynnistetään minioni uudestaan:

>sudo systemctl restart salt-minion

Katsotaan, mitä kävi:

![screenshot-3](/assignments/h1-hello-salt/screenshots/screenshot-3.png)

Jaha, Salt ei salli tabulaattorin käyttöä asetuksissa. Poistetaan ne:

>sudo sed -i 's/\t/ /g' /etc/salt/minion 

Uusi yritys:

![screenshot-5](/assignments/h1-hello-salt/screenshots/screenshot-5.png)

Kaikki ok. Laitetaan master hyväksymään minionin avain:

![screenshot-6](/assignments/h1-hello-salt/screenshots/screenshot-6.png)

![screenshot-7](/assignments/h1-hello-salt/screenshots/screenshot-7.png)

Ajetaan pari komentoa testiksi:

![screenshot-8](/assignments/h1-hello-salt/screenshots/screenshot-8.png)

![screenshot-9](/assignments/h1-hello-salt/screenshots/screenshot-9.png)

Toimii.

---

#### <a id="tehtava2">2. Kokeile esimerkkiä</a>

Yritän ottaa mallia [Joona Leppälahden](https://github.com/joonaleppalahti/CCM/blob/master/salt/srv/salt/firewall.sls) firewall statuksesta, mutta käyttämällä pelkkää iptablesia.
Luodaan statukselle hakemisto ja tiedosto, joka pitää sisällään halutut iptables-säännöt:

![screenshot-10](/assignments/h1-hello-salt/screenshots/screenshot-10.png)

![screenshot-11](/assignments/h1-hello-salt/screenshots/screenshot-11.png)

IPv6 ei ole käytössä, joten tämä riittää.
Nollataan olemassaolevat säännöt ja sallitaan kaikki sisääntuleva liikenne (SSH on käytössä, joten laitan komennot peräkkäin, että en lukitsisi itseäni ulos):

![screenshot-12](/assignments/h1-hello-salt/screenshots/screenshot-12.png)

Luodaan itse status:

![screenshot-13](/assignments/h1-hello-salt/screenshots/screenshot-13.png)

Kokeillaan:

![screenshot-14](/assignments/h1-hello-salt/screenshots/screenshot-14.png)

Hups, iptables.rules on väärässä hakemistossa. Korjataan asia:

![screenshot-15](/assignments/h1-hello-salt/screenshots/screenshot-15.png)

Uusi yritys:

![screenshot-16](/assignments/h1-hello-salt/screenshots/screenshot-16.png)

Tiedostoa ei löydy? Löytyypäs:

![screenshot-17](/assignments/h1-hello-salt/screenshots/screenshot-17.png)

En keksi ratkaisua :(
Moving on.

---

#### <a id="tehtava3">3. Tietojen kerääminen grainsilla</a>

Kerätään tietoja minionista Saltin grains-toiminnon avulla:

>sudo salt 'ubuserver' grains.items

Tietoja tulee rivikaupalla. Tallennetaan ne tiedostoon ja lasketaan samalla rivien määrä:

![screenshot-18](/assignments/h1-hello-salt/screenshots/screenshot-18.png)

Tässä esimerkki ensimmäisestä less-ruudullisesta:

![screenshot-19](/assignments/h1-hello-salt/screenshots/screenshot-19.png)

Kokeillaan vielä jonkin tietyn tiedon pyytämistä minionilta:

![screenshot-20](/assignments/h1-hello-salt/screenshots/screenshot-20.png)

Kaikki grains-komennot saa listattua seuraavasti:

>sudo salt '*' grains.ls

---

#### <a id="tehtava4">4. Omaa kokeilua</a>

Kokeilen tehdä pilvipalvelimestani minionin ja siirtää palvelimen asetustiedostoja masterille myöhempää käyttöä varten. Todellisuudessa tämä olisi järkevämpi tehdä esim. Gitin avulla, mutta kokeillaan kuitenkin.
Palvelimella on käyttöjärjestelmänä Arch Linuxiin pohjautuva Parabola.
Asennan Saltin:

![screenshot-21](/assignments/h1-hello-salt/screenshots/screenshot-21.png)

~~Avaan tarvittavat portit pilvipalvelimen palomuuriin:~~

![screenshot-22](/assignments/h1-hello-salt/screenshots/screenshot-22.png)

~~Otan uuden säännön käyttöön:~~

>~~su~~\
>~~iptables-restore < /etc/iptables/iptables.rules.wg~~\
>~~exit~~

**Edit:** Tajusin jälkeenpäin, että tämä oli täysin turhaa. Kaikki data koneiden välillä kulkee jo-sallitun Wireguard-tunnelin kautta (_-A INPUT -i wg0 -j ACCEPT_).

Muokkaan palvelimen salt-minionin osoittamaan masteria kohti ja käynnistän sen.
Vilkaisen, näkeekö masteri sitä:

![screenshot-23](/assignments/h1-hello-salt/screenshots/screenshot-23.png)

Kyllä, uusi avain oli odottamassa.
Jotta tiedostojen siirto minionilta masterille cp-moduulilla olisi mahdollista, täytyy ensin muokata masterin asetuksia:

>sudo nano /etc/salt/master

![screenshot-24](/assignments/h1-hello-salt/screenshots/screenshot-24.png)

>sudo systemctl restart salt-master

Kokeillaan hakea minionilta tiedostoja:

![screenshot-25](/assignments/h1-hello-salt/screenshots/screenshot-25.png)

Näyttää toimivan. Tarkistetaan vielä, saapuivatko tiedostot:

![screenshot-26](/assignments/h1-hello-salt/screenshots/screenshot-26.png)

Siellähän ne.
