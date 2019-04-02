# H1

### Tehtävänanto:

* Asenna Salt Master ja Slave pull-arkkitehtuurilla (eli master on 
server). Voit laittaa herran ja orjan myös samalle koneelle. Kokeile 
suorittamalla salt:illa komentoja etänä.

* Kokeile jotain [Laineen esimerkistä](https://github.com/joonaleppalahti/CCM/tree/master/salt/srv/salt) lainattua tilaa tai tee jostain 
tilasta oma muunnelma. Muista testata lopputuloksen toimivuus. Huomaa, 
että varastossa on myös keskeneräisiä esimerkkejä, kuten 
Battlenet-asennus Windowsille.

* Kerää laitetietoja koneilta saltin grains-mekanismilla.

* Oikeaa elämää. Säädä Saltilla jotain pientä, mutta oikeaa esimerkiksi
omalta koneeltasi tai omalta virtuaalipalvelimelta. (Kannattaa kokeilla
Saltia oikeassa elämässä, mutta jos se ei onnistu, rakenna jotain 
oikeaa konettasi vastaava virtuaaliympäristö ja tee asetus siinä).

---

Käytössä on juuri asennettu ja päivitetty Ubuntu 18.04.2 LTS, joten aloitan laittamalla SSH-asetukset ja palomuurin (pelkkä iptables) kuntoon.
Kun olen saanut koneeseen SSH-yhteyden, jatkan asentamalla Saltin:

>sudo add-apt-repository universe\
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

![screenshot-4](/assignments/H1/images/screenshot-4.png)

Uusi yritys:

![screenshot-5](/assignments/H1/images/screenshot-5.png)

Kaikki ok. Laitetaan master hyväksymään minionin avain:

![screenshot-6](/assignments/H1/images/screenshot-6.png)

![screenshot-7](/assignments/H1/images/screenshot-7.png)

Ajetaan pari komentoa testimielessä:

![screenshot-8](/assignments/H1/images/screenshot-8.png)

![screenshot-9](/assignments/H1/images/screenshot-9.png)

Toimii.

---

Yritän ottaa mallia Joonan firewall statuksesta, mutta käyttämällä pelkkää iptablesia.
Luodaan statukselle hakemisto ja tiedosto, joka pitää sisällään halutut iptables-säännöt:

![screenshot-10](/assignments/H1/images/screenshot-10.png)

![screenshot-11](/assignments/H1/images/screenshot-11.png)

IPv6 ei ole käytössä, joten tämä riittää.
Nollataan olemassaolevat säännöt (SSH on käytössä, joten laitan komennot peräkkäin, että yhteys ei menisi poikki):
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


