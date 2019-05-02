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

Latasin Windows-koneelle `Salt-Minion-2019.2.0-AMD64-Setup.exe`-asennusohjelman [Saltin kotisivuilta](https://docs.saltstack.com/en/latest/topics/installation/windows.html) ja käynnistin sen:\
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

Näytti toimivan. Tarkistetaan vielä:\
![getvm-success](/assignments/H5/images/getvm-success.png)

Onnistui. `TestVM` pyörii iloisesti.

Lopuksi siistin tilaa hieman Jinjalla (HUOM pakeneminen 2. rivillä, `'C:\\'`):\
![jinja](/assignments/H5/images/jinja.png)

---

### 2. Windowsin säätöä Saltilla paikallisesti

