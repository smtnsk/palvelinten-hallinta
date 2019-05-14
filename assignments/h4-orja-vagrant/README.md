## H4 - Orja -skripti ja Vagrant

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Tee skripti, joka tekee koneestasi salt-orjan.

2. Asenna Vagrant. Kokeile jotain uutta kuvaa Atlaksesta. Huomaa, että kuvat ovat vieraita binäärejä, ja virtuaalikoneista on mahdollista murtautua ulos. Jokohan Ubuntun virallinen  Suodatin: VirtualBox, järjestys: Most downloads. https://app.vagrantup.com/boxes/search?provider=virtualbox

#### Ympäristö:

Hyper-V nimettömällä pöytäkoneella, isäntänä Windows Embedded 8.1 Industry Pro x64:\
![neofetch-minion](/assignments/H4/images/neofetch-minion.png)

---

### 1. Orja -skripti

Loin skriptin `minionize.sh`. Aloitin skriptin salt-asennuksella:\
![script-install](/assignments/H4/images/script-install.png)

Kokeilin ajaa skriptin:\
![run-install](/assignments/H4/images/run-install.png)

Hyvin toimi.\
Seuraavaksi on vuorossa `/etc/salt/minion` -tiedoston muokkaaminen.\
`awk` ja `sed` ovat kiinnostaneet jo pitkään, joten ajattelin, että nyt on oiva hetki kokeilla tehdä niillä jotain. Aloitin `sed`illä ja sain niin nopeasti sopivan komennon kasaan, että `awk` jäi kokeilematta:\
![sed](/assignments/H4/images/sed.png)

Lisäsin komennon skriptiin ja muokkasin sen ottamaan masterin ja id:n argumentteina.\
Lisäsin myös tarkistuksen, että skripti ajetaan sudo-oikeuksilla, salt-minionin uudelleenkäynnistyksen, sekä väliaikatietojen tulostuksen:\
![script-finished](/assignments/H4/images/script-finished.png)

Lopputulos (julkiset IP-osoitteet piilotettu):\
![results](/assignments/H4/images/results.png)

**Edit**: Yllä olevassa esimerkissä annoin minionille nimeksi `<julkinen IP>-<hostname>`, mutta parempi idea on totta kai käyttää verkon sisäistä IP-osoitetta. Se onnistuu syöttämällä skriptin toiseksi argumentiksi `$(hostname -I)-$HOSTNAME`.

Ajoin skriptin vielä huvikseni Shellcheckin läpi, ei löytynyt ongelmia:
![shellcheck](/assignments/H4/images/shellcheck.png)

---

### 2. Vagrant

(Huom: hostname on muuttunut tehtävien välillä, kyseessä on kuitenkin tismalleen sama järjestelmä)

Package manager ei löytänyt Virtualboxia. Seurasin [ohjeita Virtualboxin nettisivulta](https://www.virtualbox.org/wiki/Linux_Downloads) asian korjaamiseksi.\
Aloitin lataamalla Oraclen julkiset avaimet:\
![oracle-keys](/assignments/H4/images/oracle-keys.png)

Lisäsin Virtualbox-repositorion `/etc/apt/sources.list` -tiedostoon:\
![apt-sources](/assignments/H4/images/apt-sources.png)

Päivitin järjestelmän tiedot:\
![apt-update](/assignments/H4/images/apt-update.png)

Nyt Virtualboxin asennus onnistui:\
![apt-install-virtualbox](/assignments/H4/images/apt-install-virtualbox.png)

Asensin seuraavaksi Vagrantin komennolla `sudo apt-get install vagrant`.\

`vagrant init` onnistui...\
![vagrant-init](/assignments/H4/images/vagrant-init.png)

...mutta `vagrant up --provider virtualbox` ei:\
![vagrant-fail](/assignments/H4/images/vagrant-fail.png)

Ok, Virtualbox 6.0 ei siis kelpaa. Poistin sen ja asensin 5.2:n, `sudo apt-get remove virtualbox-6.0 -y && sudo apt-get install virtualbox-5.2 -y`

Nyt `ubuntu/trusty64`:n asennus lähti käyntiin:\
![vagrant-success](/assignments/H4/images/vagrant-success.png)

Mutta VM ei käynnisty, tulee timeout:\
![vagrant-fail-2](/assignments/H4/images/vagrant-fail-2.png)

Timeout tapahtuu tässä vaiheessa:\
![vagrant-fail-3](/assignments/H4/images/vagrant-fail-3.png)

Pikaisella etsimisellä netistä ei löytynyt apua, enkä ehdi tutkia asiaa enempää tällä hetkellä. Jatkoa seuraa.
