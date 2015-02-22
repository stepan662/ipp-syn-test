# README #

### Testy k IPP projektu SYN (zvýraznění syntaxe) ###

Snažil jsem se obsáhnout co nejvíce věcí ze zadání, ale je dost pravděpodobné, že jsem něco přehlídl či špatně pochopil. 

### Jak to nastavit, aby to fungovalo? ###

```
ipp-syn-test
 | - test.sh
 \ - ...
ipp-syn
 | - syn.php
 \ - ...
```

1. Naklonujte si testy do složky vedle vašeho projektu, struktura složek je znázorněna výše
2. V souboru `test.sh` nastavte proměnné:
    * `SCRIPT` na relativni adresu k vašemu projektu (např. `../ipp-syn/syn.php`)
    * `INTERPRETER` na `php` (python by měl taky fungovat) na merlinovi je nutné zadat `php -d open_basedir=""`
3. Spusťe ve složce s testy příkazem `./test.sh`
4. Jsou zahrnuty i testy na zkrácené parametry a rozšíření HTM, což není povinné

### Co dělat když najdu chybu v testu? ###
Projděte nejdříve prosím:

1. [obecné zadání](https://wis.fit.vutbr.cz/FIT/st/course-files-st.php/course/IPP-IT/projects/2014-2015/Zadani/proj2015.pdf?cid=9999)
2. [konkrétní zadání](https://wis.fit.vutbr.cz/FIT/st/course-files-st.php/course/IPP-IT/projects/2014-2015/Zadani/syn.pdf?cid=9999)
3. [fórum](https://wis.fit.vutbr.cz/FIT/st/course-sl.php?id=561253)
4. wiki a FAQ

Když to opravdu bude chyba potom mi prosím pošlete email nebo můžete přímo napsat na fórum.

### Kontakt ###

* email: `granat.stepan@gmail.com`
* nebo na `FB`