## H4 - Orja -skripti ja Vagrant

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Tee skripti, joka tekee koneestasi salt-orjan.

2. Vagrant. Asenna Vagrant. Kokeile jotain uutta kuvaa Atlaksesta. Huomaa, että kuvat ovat vieraita binäärejä, ja virtuaalikoneista on mahdollista murtautua ulos. Jokohan Ubuntun virallinen  Suodatin: VirtualBox, järjestys: Most downloads. https://app.vagrantup.com/boxes/search?provider=virtualbox

#### Ympäristö:

**Master** (pilvipalvelin):\
![neofetch-master](/assignments/H4/images/neofetch-master.png)

**Minion** (Hyper-V nimettömällä pöytäkonellä):\
![neofetch-minion](/assignments/H4/images/neofetch-minion.png)
Isäntäkoneella Windows Embedded 8.1 Industry Pro x64.

---

### 1. Orja -skripti

Loin skriptin `minionize.sh`. Aloitin skriptin salt-asennuksella:\
![script-install](/assignments/H4/images/script-install.png)

Kokeilin ajaa skriptin:
![run-install](/assignments/H4/images/run-install.png)

Hyvin toimi.\
Seuraavaksi on vuorossa `/etc/salt/minion` -tiedoston muokkaaminen\
`awk` ja `sed` ovat kiinnostaneet jo pitkään, joten ajattelin, että nyt on oiva hetki kokeilla tehdä niillä jotain. Aloitin `sed`illä ja sain niin nopeasti sopivan komennon kasaan, että `awk` jäi kokeilematta:\
![sed](/assignments/H4/images/sed.png)

Lisäsin komennon skriptiin ja muokkasin sen ottamaan masterin ja id:n argumentteina.\
Lisäsin myös tarkistuksen, että skripti ajetaan sudo-oikeuksilla, salt-minionin uudelleenkäynnistyksen, sekä väliaikatietojen tulostuksen:
![script-finished](/assignments/H4/images/script-finished.png)

Lopputulos (julkiset IP-osoitteet piilotettu):\
![results](/assignments/H4/images/results.png)

---

TODO
