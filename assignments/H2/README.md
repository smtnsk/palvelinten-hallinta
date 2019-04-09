## H2 - Package-file-server.

http://terokarvinen.com/2018/aikataulu-palvelinten-hallinta-ict4tn022-3003-ti-ja-3001-to-loppukevat-2019

#### Tehtävänanto (torstain ryhmä):

1. Asenna SSH eri porttiin Package-File-Service rakenteella. Käytä service:watch -tekniikkaa niin, että demoni käynnistyy uudelleen, kun asetustiedosto muuttuu.

2. Asenna Apache käsin niin, että käyttäjien kotisivut näkyvät. Etsi muutetut tiedostot komennolla ‘find /etc/ -printf ‘%T+ %p\n’|sort’. (Muista korjata lainausmerkit oikeiksi, automaattimuotoilu usein sotkee ne). Yritä nyt tehdä tila, joka asettaa nuo tiedostot (file.symlink) paikoilleen.

3. Eri package-file-service. Tee package-file-service tilalla jokin eri asetus tai asennus kuin tunnilla ja tehtävän muissa kohdissa.

---

