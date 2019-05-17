## H4 - Orja -skripti ja Vagrant

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. [Tee skripti, joka tekee koneestasi salt-orjan.](#tehtava1)

2. [Asenna Vagrant. Kokeile jotain uutta kuvaa Atlaksesta. Huomaa, että kuvat ovat vieraita binäärejä, ja virtuaalikoneista on mahdollista murtautua ulos.](#tehtava2)

#### Ympäristö:

Hyper-V nimettömällä pöytäkoneella, isäntänä Windows Embedded 8.1 Industry Pro x64:\
![neofetch-minion](/assignments/h4-orja-vagrant/screenshots/neofetch-minion.png)

---

### <a id="tehtava1">1. Orja -skripti</a>

Loin skriptin `minionize.sh`. Aloitin skriptin salt-asennuksella:\
![script-install](/assignments/h4-orja-vagrant/screenshots/script-install.png)

Kokeilin ajaa skriptin:\
![run-install](/assignments/h4-orja-vagrant/screenshots/run-install.png)

Hyvin toimi.\
Seuraavaksi on vuorossa `/etc/salt/minion` -tiedoston muokkaaminen.\
`awk` ja `sed` ovat kiinnostaneet jo pitkään, joten ajattelin, että nyt on oiva hetki kokeilla tehdä niillä jotain. Aloitin `sed`illä ja sain niin nopeasti sopivan komennon kasaan, että `awk` jäi kokeilematta:\
![sed](/assignments/h4-orja-vagrant/screenshots/sed.png)

Lisäsin komennon skriptiin ja muokkasin sen ottamaan masterin ja id:n argumentteina.\
Lisäsin myös tarkistuksen, että skripti ajetaan sudo-oikeuksilla, salt-minionin uudelleenkäynnistyksen, sekä väliaikatietojen tulostuksen:\
![script-finished](/assignments/h4-orja-vagrant/screenshots/script-finished.png)

Lopputulos (julkiset IP-osoitteet piilotettu):\
![results](/assignments/h4-orja-vagrant/screenshots/results.png)

**Edit**: Yllä olevassa esimerkissä annoin minionille nimeksi `<julkinen IP>-<hostname>`, mutta parempi idea on totta kai käyttää verkon sisäistä IP-osoitetta. Se onnistuu syöttämällä skriptin toiseksi argumentiksi `$(hostname -I)-$HOSTNAME`.

Ajoin skriptin vielä huvikseni Shellcheckin läpi, ei löytynyt ongelmia:
![shellcheck](/assignments/h4-orja-vagrant/screenshots/shellcheck.png)

---

### <a id="tehtava2">2. Vagrant</a>

(Huom: hostname on muuttunut tehtävien välillä, kyseessä on kuitenkin tismalleen sama järjestelmä)

Package manager ei löytänyt Virtualboxia. Seurasin [ohjeita Virtualboxin nettisivulta](https://www.virtualbox.org/wiki/Linux_Downloads) asian korjaamiseksi.\
Aloitin lataamalla Oraclen julkiset avaimet:\
![oracle-keys](/assignments/h4-orja-vagrant/screenshots/oracle-keys.png)

Lisäsin Virtualbox-repositorion `/etc/apt/sources.list` -tiedostoon:\
![apt-sources](/assignments/h4-orja-vagrant/screenshots/apt-sources.png)

Päivitin järjestelmän tiedot:\
![apt-update](/assignments/h4-orja-vagrant/screenshots/apt-update.png)

Nyt Virtualboxin asennus onnistui:\
![apt-install-virtualbox](/assignments/h4-orja-vagrant/screenshots/apt-install-virtualbox.png)

Asensin seuraavaksi Vagrantin komennolla `sudo apt-get install vagrant`.

`vagrant init` onnistui...\
![vagrant-init](/assignments/h4-orja-vagrant/screenshots/vagrant-init.png)

...mutta `vagrant up --provider virtualbox` ei:\
![vagrant-fail](/assignments/h4-orja-vagrant/screenshots/vagrant-fail.png)

Ok, Virtualbox 6.0 ei siis kelpaa. Poistin sen ja asensin 5.2:n, `sudo apt-get remove virtualbox-6.0 -y && sudo apt-get install virtualbox-5.2 -y`

Nyt `ubuntu/trusty64`:n asennus lähti käyntiin:\
![vagrant-success](/assignments/h4-orja-vagrant/screenshots/vagrant-success.png)

Mutta VM ei käynnisty, tulee timeout:\
![vagrant-fail-2](/assignments/h4-orja-vagrant/screenshots/vagrant-fail-2.png)

Timeout tapahtuu tässä vaiheessa:\
![vagrant-fail-3](/assignments/h4-orja-vagrant/screenshots/vagrant-fail-3.png)

Pikaisella etsimisellä netistä ei löytynyt apua, enkä ehdi tutkia asiaa enempää tällä hetkellä.
