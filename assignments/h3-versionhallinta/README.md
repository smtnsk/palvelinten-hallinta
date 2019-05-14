## H3 - Versionhallinta

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Näytä omalla salt-varastollasi esimerkit komennoista ‘git log’, ‘git diff’ ja ‘git blame’. Selitä tulokset.

2. Tee tyhmä muutos gittiin, älä tee commit:tia. Tuhoa huonot muutokset ‘git reset –hard’. Huomaa, että tässä toiminnossa ei ole peruutusnappia.

3. Tee uusi salt-moduli. Voit asentaa ja konfiguroida minkä vain uuden ohjelman: demonin, työpöytäohjelman tai komentokehotteesta toimivan ohjelman. Käytä tarvittaessa ‘find -printf “%T+ %p\n”|sort’ löytääksesi uudet asetustiedostot.

#### Ympäristö:

Hyper-V -virtuaalikoneella pyörivä Ubuntu 18.04.2 LTS x64, isäntäkoneella Windows Embedded 8.1 Industry Pro x64.

![system](/assignments/h3-versionhallinta/screenshots/neofetch.png)

---

#### Aloitus

Laitoin aluksi käyttäjäasetukset kuntoon:\
![git-config](/assignments/h3-versionhallinta/screenshots/git-config.png)

Jatkoin kloonamalla tätä tehtävää varten luomani repositorion:\
![git-clone](/assignments/h3-versionhallinta/screenshots/git-clone.png)

---

### 1. Komennot ‘git log’, ‘git diff’ ja ‘git blame’.

#### 1.1 Log

Tein muutoksen readmeen:\
![edit-readme](/assignments/h3-versionhallinta/screenshots/edit-readme.png)

Add, commit ja log:\
![git-log](/assignments/h3-versionhallinta/screenshots/git-log.png)

`git log` näyttää repositorion commit historian uusimmasta vanhimpaan. Yllä olevassa kuvassa siis näemme alhaalla repositorion luomisen ja sen yllä `README.md` -tiedoston muokkauksen. Huomaamme myös, että virtuaalikoneeni kello on väärässä ajassa.

#### 1.2 Diff

Loin uuden tiedoston `hello.sh`:\
![touch](/assignments/h3-versionhallinta/screenshots/touch.png)

Kutsuin tässä välissä `git add .`
Muokkasin tiedostoa ja katsoin mitä `git diff` sanoo:\
![git-diff](/assignments/h3-versionhallinta/screenshots/git-diff.png)

`git diff` näyttää mitä muutoksia edellisen indeksin päivityksen (`git add`) jälkeen on tapahtunut. Yllä näemme siis `hello.sh` tiedoston alkuperäisen ja muokatun tilan eron. Rivit joiden edessä on `+` -merkki ovat uusia.

#### 1.3 Blame

`git blame` ennen committia ja commitin jälkeen:\
![git-blame](/assignments/h3-versionhallinta/screenshots/git-blame.png)

Jaha, viimeisin muutos jäi välistä. Toistin prosessin:\
![git-blame-2](/assignments/h3-versionhallinta/screenshots/git-blame-2.png)

`git blame <file>` kertoo rivi riviltä missä commitissa se on tiedostoon lisätty ja kuka commitin on tehnyt.

---

### 2 Tuhoa huonot muutokset ‘git reset –hard’ -komennolla

Muokkasin `hello.sh` -tiedostoa ja palautin sitten repositorion muokkausta edeltävään tilaan `git reset --hard` -komennolla:\
![git-reset](/assignments/h3-versionhallinta/screenshots/git-reset.png)

---

### 3. Salt -moduli

Asensin ja konfiguroin minionille [dnscrypt-proxyn](https://github.com/jedisct1/dnscrypt-proxy).

Aloitin luomalla dnscrypt-proxy -tilalle oman hakemiston ja loin alustavan tilan, joka asentaa itse ohjelman:\
![dnscrypt-mkdir](/assignments/h3-versionhallinta/screenshots/dnscrypt-mkdir.png)
![dnscrypt-sls-1](/assignments/h3-versionhallinta/screenshots/dnscrypt-sls-1.png)

Tarkistin, että tila toimii:\
![dnscrypt-installed](/assignments/h3-versionhallinta/screenshots/dnscrypt-installed.png)

Jatkoin luomalla minionin dnscrypt-proxylle konfiguraatiotiedoston. Käytin mallina masterin omaa konfiguraatiota:\
(tarvitsin sudotetun shellin, jotta redirection toimisi)\
![dnscrypt-toml-1](/assignments/h3-versionhallinta/screenshots/dnscrypt-toml-1.png)

Lisäsin tiedoston alkuun huomautuksen ja rajasin kuuntelun localhostiin:\
![dnscrypt-toml-2](/assignments/h3-versionhallinta/screenshots/dnscrypt-toml-2.png)
![dnscrypt-toml-final](/assignments/h3-versionhallinta/screenshots/dnscrypt-toml-final.png)

Muokkasin tilaa niin, että `dnscrypt-proxy.toml` peilataan minionille:\
![dnscrypt-sls-2](/assignments/h3-versionhallinta/screenshots/dnscrypt-sls-2.png)

Tarkistus:\
![dnscrypt-managed-file-1](/assignments/h3-versionhallinta/screenshots/dnscrypt-managed-file-1.png)

Vielä minionin puolelta:\
![dnscrypt-managed-file-2](/assignments/h3-versionhallinta/screenshots/dnscrypt-managed-file-2.png)

Toimihan se.

Laitoin vielä dnscrypt-proxyn käynnistymään uudelleen tiedoston muuttuessa, sekä korvasin minionin `resolv.conf` -tiedoston (se osoittaa Ubuntulla oletuksena osoitteeseen `127.0.0.53`, mutta asetin dnscrypt-proxyn kuuntelemaan `127.0.0.1`):\
![dnscrypt-sls-final](/assignments/h3-versionhallinta/screenshots/dnscrypt-sls-final.png)

![resolv-conf](/assignments/h3-versionhallinta/screenshots/resolv-conf.png)

Tarkistus:\
![dnscrypt-service](/assignments/h3-versionhallinta/screenshots/dnscrypt-service.png)

Ja minionin puolella:\
![dnscrypt-not-working](/assignments/h3-versionhallinta/screenshots/dnscrypt-not-working.png)

Mähnä, ei toimi. Nyt loppui kuitenkin aika, joten en ehdi taistelemaan dnscryptin kanssa enempää.

**Edit:** Ach, unohdin muuttaa järjestelmän DNS-asetukset (Ubuntussa `/etc/netplan/`). Ilmankos ei toiminut.
