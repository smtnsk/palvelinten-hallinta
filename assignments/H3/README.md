## H3 - Versionhallinta

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Näytä omalla salt-varastollasi esimerkit komennoista ‘git log’, ‘git diff’ ja ‘git blame’. Selitä tulokset.

2. Tee tyhmä muutos gittiin, älä tee commit:tia. Tuhoa huonot muutokset ‘git reset –hard’. Huomaa, että tässä toiminnossa ei ole peruutusnappia.

3. Tee uusi salt-moduli. Voit asentaa ja konfiguroida minkä vain uuden ohjelman: demonin, työpöytäohjelman tai komentokehotteesta toimivan ohjelman. Käytä tarvittaessa ‘find -printf “%T+ %p\n”|sort’ löytääksesi uudet asetustiedostot.

#### Ympäristö:

Hyper-V -virtuaalikoneella pyörivä Ubuntu 18.04.2 LTS x64, isäntäkoneella Windows Embedded 8.1 Industry Pro x64.

![git-clone](/assignments/H3/images/neofetch.png)

---

#### Aloitus

Laitoin aluksi käyttäjäasetukset kuntoon:\
![git-config](/assignments/H3/images/git-config.png)

Jatkoin kloonamalla tätä tehtävää varten luomani repositorion:\
![git-clone](/assignments/H3/images/git-clone.png)

---

### 1. Komennot ‘git log’, ‘git diff’ ja ‘git blame’.

#### 1.1 Log

Tein muutoksen readmeen:\
![edit-readme](/assignments/H3/images/edit-readme.png)

Add, commit ja log:\
![git-log](/assignments/H3/images/git-log.png)

`git log` näyttää repositorion commit historian uusimmasta vanhimpaan. Yllä olevassa kuvassa siis näemme alhaalla repositorion luomisen ja sen yllä `README.md` -tiedoston muokkauksen. Huomaamme myös, että virtuaalikoneeni kello on väärässä ajassa.

#### 1.2 Diff

Loin uuden tiedoston `hello.sh`:\
![new-file](/assignments/H3/images/new-file.png)

Kutsuin tässä välissä `git add .`
Muokkasin tiedostoa ja katsoin mitä `git diff` sanoo:\
![git-diff](/assignments/H3/images/git-diff.png)

`git diff` näyttää mitä muutoksia edellisen indeksin päivityksen (`git add`) jälkeen on tapahtunut. Yllä näemme siis `hello.sh` tiedoston alkuperäisen ja muokatun tilan eron. Rivit joiden edessä on `+` -merkki ovat uusia.

#### 1.3 Blame

`git blame` ennen committia ja commitin jälkeen:\
![git-blame](/assignments/H3/images/git-blame.png)

Jaha, viimeisin muutos jäi välistä. Toistin prosessin:\
![git-blame-2](/assignments/H3/images/git-blame-2.png)

`git blame <file>` kertoo rivi riviltä missä commitissa se on tiedostoon lisätty ja kuka commitin on tehnyt.

---

### 2 Tuhoa huonot muutokset ‘git reset –hard’ -komennolla

Muokkasin `hello.sh` -tiedostoa ja palautin sitten repositorion muokkausta edeltävään tilaan `git reset --hard` -komennolla:\
![git-reset](/assignments/H3/images/git-reset.png)

---

### 3. Salt -moduli

TODO
