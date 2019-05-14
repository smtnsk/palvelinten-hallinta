## H5 - Windowsin hallinta Saltilla

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto:

1. Säädä Windowsia Saltilla siten, että Windows on orja ja Linux on herra.

2. Säädä Windowsia Saltilla ilman herra-orja rakennetta (salt-call –local)

3. Muuta jonkin Windows-ohjelman asetuksia Saltilla. Monia ohjelmia voi säätää laittamalla asetustiedoston paikalleen, aivan kuten Linuxissa.

4. Vapaaehtoinen: tee omaan käytössä olevaan (Windows, jos käytät Windowsia) koneeseesi Saltilla jokin säätö, josta on sinulle hyötyä jokapäiväisessä elämässä.

#### Ympäristö:

Minionina Windows Embedded 8.1 Industry Pro x64 nimettömällä pöytäkoneella:\
![windows-info](/assignments/H5/images/win-info.png)

Masterina Parabola GNU/Linux-libre x64 pilvipalvelimella:
![linux-info](/assignments/H5/images/linux-info.png)

---

### 0. Aloitus

Tarkistin masterilla, mikä `salt-master` -versio on käytössä:\
![master-version-1](/assignments/H5/images/master-version-1.png)

Tuo Pyytton-varoitus on tullut esille aiemminkin ja se on alkanut hiertää. Katsoin, mitä löytyy `/usr/lib/python2.7/site-packages/salt/scripts.py`:n riviltä 102:\
![python-warning-1](/assignments/H5/images/python-warning-1.png)

Ok. Estin sitä ulisemasta:\
![python-warning-2](/assignments/H5/images/python-warning-2.png)

`salt-master` -versio:\
![master-version-2](/assignments/H5/images/master-version-2.png)

Latasin Windows-minionille `Salt-Minion-2019.2.0-AMD64-Setup.exe`-asennusohjelman [Saltin kotisivuilta](https://docs.saltstack.com/en/latest/topics/installation/windows.html) ja käynnistin sen:\
![win-install](/assignments/H5/images/win-install.png)

Syötin asennuksen aikana masterin ip:n ja minionin id:n, kun niitä kysyttiin.\
Asennus sujui ongelmitta. Hyväksyin avaimen masterilla:\
![salt-key](/assignments/H5/images/salt-key.png)

---

### 1. Windowsin säätöä Linuxista käsin

Kokeilin aluksi ajaa jotain yksinkertaista komentoa:\
![cmd-run-1](/assignments/H5/images/cmd-run-1.png)

Ei onnistunut. Ilmeisesti PowerShell-komentoja ei voi ajaa suoraan. [Ratkaisu löytyi Saltin dokumentaatiosta](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.cmdmod.html), uuri yritys:\
![cmd-run-2](/assignments/H5/images/cmd-run-2.png)

Toimi.\
Päätin tehdä seuraavaksi tilan, joka luo uuden Hyper-V -virtuaalikoneen. Saltissa ei ole valmista Hyper-V -modulia, joten ajatukseni on kirjoittaa PowerShell-skripti, siirtää se masterilta minionille ja ajaa se.

Aloitin luomalla hakemiston `/srv/salt/hyperv` ja sinne tiedoston `create-vm.ps1`:\
![vm-script](/assignments/H5/images/vm-script.png)

Seuraavaksi loin itse tilan, `/srv/salt/hyperv/init.sls`:\
![hyperv-state](/assignments/H5/images/hyperv-state.png)

Ajoin tilan:\
![scripts-not-allowed](/assignments/H5/images/scripts-not-allowed.png)

Ahaa, skriptien ajaminen oli kielletty. Kokeilin, voiko execution policyn muuttaa Saltin kautta:\
![hyperv-state-executionpolicy](/assignments/H5/images/hyperv-state-executionpolicy.png)

Ajoin tilan:\
![hyperv-state-success](/assignments/H5/images/hyperv-state-success.png)

Näytti toimivan. Tarkistin vielä:\
![getvm-success](/assignments/H5/images/getvm-success.png)

Onnistui. `TestVM` pyöri iloisesti.

Lopuksi siistin tilaa hieman Jinjalla (HUOM pakeneminen 2. rivillä, `'C:\\'`):\
![jinja](/assignments/H5/images/jinja.png)

---

### 2. Windowsin säätöä Saltilla paikallisesti

Tässä on oiva tilaisuus kokeilla käyttää Salttia package managerina. Let's asennetaan.

Aluksi yritin päivittää package repositorion:\
![pkg-refresh-fail](/assignments/H5/images/pkg-refresh-fail.png)

Hmm, mitään ei tapahtunut. Selasin [dokumentaatiota](https://docs.saltstack.com/en/latest/topics/windows/windows-package-manager.html) ja huomasin, että ensin masterilla pitää kutsua `salt-run winrepo.update_git_repos`, joten kokeilin sitä:\
![winrepo-1](/assignments/H5/images/winrepo-1.png)

Jaha. Kokeilin ajaa komennon minionilla (HUOM `salt-call` vs. `salt-run`):\
![winrepo-2](/assignments/H5/images/winrepo-2.png)

Tosiaan, minionilla ei ole Git asennettuna. Asensin sen käsin, kun kerran masterilla oli ongelmia.

Yritin asennuksen jälkeen uudestaan, mutta nyt tuli valituksia, että Pyyttonia ei löydy. Lisäsin sen pathiin, `$env:path="$env:Path;C:\Users\smtnskn\AppData\Local\Programs\Python\Python37"`.

Uusi yritys:\
![winrepo-3](/assignments/H5/images/winrepo-3.png)

Näytti toimivan, vaikka pukkasikin virheitä. Kokeilin ajaa `salt-call --local pkg.refresh_db`:\
![pkg-refresh-success](/assignments/H5/images/pkg-refresh-success.png)

Asensin lopuksi puttyn:\
![putty-1](/assignments/H5/images/putty-1.png)\
![putty-2](/assignments/H5/images/putty-2.png)

Toimi. Kaikkia muita paketteja joita yritin asentaa ei Salt kuitenkaan löytänyt (`rufus, cmder, cygwin, testdisk`).

---

### 3. Windows -konfiguraatio Saltilla

Suunnitelmana on lisätä Explorerin context menuun Disk Cleanup -toiminto rekisteriä muokkaamalla. Sain idean [täältä](https://www.online-tech-tips.com/windows-8/windows-8-registry-tweaks/).

Tämän voisi helposti toteuttaa PowerShell-skriptillä kuten tein yllä, mutta huomasin, että [Saltissa on valmiina toiminto Windowsin rekisterin muokkaamiseen](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.reg.html), joten kokeilin sitä.

Loin hakemiston `/srv/salt/winreg` ja sinne tilan `init.sls`:\
![winreg-sls-1](/assignments/H5/images/winreg-sls-1.png)

Kokeilin ajaa tilan:\
![winreg-apply-1](/assignments/H5/images/winreg-apply-1.png)

Ok, näytti toimivan. Tein tilan loppuun:\
![winreg-sls-2](/assignments/H5/images/winreg-sls-2.png)

Kokeilin ajaa uudestaan:\
![winreg-apply-token-error](/assignments/H5/images/winreg-apply-token-error.png)

Epäilin ongelmaksi `@` -merkkiä, joten: `sed -i 's/@/"@"/' init.sls`.\
Uusi yritys:\
![winreg-apply-2](/assignments/H5/images/winreg-apply-2.png)

No niin! Tarkistin tilanteen vielä Windows-minionin puolelta:\
![regedit-confirm](/assignments/H5/images/regedit-confirm.png)

Muutokset olivat onnistuneet. Käynnistin minionin uudelleen:\
![minion-restart](/assignments/H5/images/minion-restart.png)

Ja tarkistin context menun:\
![context-has-cleanup](/assignments/H5/images/context-has-cleanup.png)

Siellähän se. :)))

---

### 4. Salt-säätö omaan käyttöön

**TODO**
