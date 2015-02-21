#!/bin/bash
# Spusteni s parametrem "keep" zabrani smazani docasnych souboru s vystupy

BINARY="../IPP1/ipp1.php"

if [ `basename "$PWD"` != "IPP1-tests" ]; then
	cd "../IPP1-tests"
	if [ `basename "$PWD"` != "IPP1-tests" ]; then
		echo "Spustte skript ve slozce s projektem nebo ve slozce s testy."
		exit 1
	fi
fi

ok_count=0
count=0

red='\033[1;31m'
green='\033[1;32m'
NC='\033[0m'


#Pouziti: run_test	<1 vystup> <2 navratovy kod> <3 argumenty> <4 popis>
#<vystup> -  '': neporovnavej | jinak: porovnej s out/<vystup>
function run_test {
	((count++))

	printf ">>> %-7s %-59s " "Test$count" "$4"

	printf ""|php $BINARY $3 1> "test.out" 2> "err.out"
	exit_code="$?"

	if [ "$1" = "" ]; then
		diffCode="0"; 
		diffout="";
	else
		diffout="Diffout\n"`diff "test.out" "out/$1"`"\n"
		diffCode=$?
	fi

	if [ "$diffCode" = "0" ] && [ "$exit_code" = "$2" ]; then
		echo -e "[  ${green}OK${NC}  ]"
#		echo php $BINARY $2
		((ok_count++))
	else
		echo -e "[ ${red}FAIL${NC} ]"
		echo "php" "$BINARY" "$3"
		cat "err.out"
		echo "Exit code: $exit_code"
		printf "%s" "$diffout"
		echo
	fi
	rm "test.out"
	rm "err.out"
}

################################################################################

echo
echo
echo -e "\t\t\t\t\t${red}IPP1 TESTY${NC}"

echo
echo -e "${green}Testy parametrů${NC}"
echo

#								(navratovy kod)
#										 	|
#run_test<vyst. soub><e> <argumenty programu> 															<popis spusteneho testu> 					
run_test 	""					0 	"" 																								"Zadne parametry"
run_test	"" 					1 	"--input" 																				"Parametr bez hodnoty - chyba"
run_test 	""					1 	"--input=TP1 --input=TP1" 												"Duplicitni parametr - chyba"
run_test 	""					1 	"--br --br" 														 					"Duplicitni prepinac - chyba"
run_test	""					2 	"--input=bla"																			"Neexistujici input"
run_test 	""					0 	"--input=TP1 --output=TP2 --format=TP1"		 				"Vstup ok"
run_test 	""					0 	"--input='TP1'"																		"Cesta k souboru v apostrofech"
run_test	"TF2"				0 	"--input='test folder/TFI1' --format=TP1"					"Nazev slozky s mezerami apostrofy"
run_test	"TF2"				0 	"--input='TFI1' --format='test folder/TP1'"				"Nazev slozky s mezerami apostrofy"
run_test	"TF2"				0 	"--input=\"test folder/TFI1\" --format=TP1"				"Nazev slozky s mezerami uvozovky"
run_test	"TF2"				0 	"--input='TFI1' --format=\"test folder/TP1\""			"Nazev slozky s mezerami uvozovky"
run_test	""					0 	"--input='TFI1' --output='test folder/out'"				"Nazev slozky s mezerami uvozovky"
run_test	""					1 	"--input=TFI1 --format=test folder/TP1"						"Nazev slozky s mezerami bez uvozovek"

echo
echo -e "${green}Testy zkracenych parametru${NC}"
echo

run_test 	""					0 	"-h"																							"Zkraceny prepinac -h"
run_test 	"" 					0 	"-b" 																							"Zkraceny prepinac -b"
run_test	""					0 	"-i=TP1"																					"Zkraceny prepinac -i"
run_test	""					2 	"-i=bla"																					"Nexist. input zkracene"
run_test	""					0 	"-o=err.out"																			"Output zkracene"
run_test	""					1 	"--br -b"																					"Duplicitni dlouhy a zkraceny"
run_test	""					1 	"--input=TP1 -i=TP1"															"Duplicitni dlouhy a zkraceny"

echo
echo -e "${green}Testy formatovaciho souboru${NC}"
echo
run_test 	"TF1"				0 	"--format=TF1 --input=TFI1"												"FS v poradku"
run_test 	"TF1"				0 	"--format=TF2 --input=TFI1"												"FS vice tabulatoru - ok"
run_test	""					4 	"--format=TF3 --input=TFI1"												"FS chybi formatovaci cast"
run_test	""					4 	"--format=TF4 --input=TFI1"												"FS neznama form. znacka 'itali'"
run_test	""					4 	"--format=TF5 --input=TFI1"												"FS spatny format barvy"
run_test	""					4 	"--format=TF6 --input=TFI1"												"FS spatna velikost pisma"
run_test	""					4 	"--format=TF7"																		"FS ascii < 32 v regularnim vyrazu"
run_test	"TF2"				0 	"--input=TFI1"																		"FS chybi: vystup = vstup"
run_test	"TF2"				0 	"--input=TFI1 --format=bla"												"FS neexistuje: vystup = vstup"

echo
echo -e "${green}Testy spravneho formatovani${NC}"
echo

run_test	"TF6"				0 	"--input=TFI5 --format=TF10"											"Jednoduche formatovani"
run_test	"TF7"				0 	"--input=TFI6 --format=TF11"											"Aplikovani tagu ve spravnem poradi"
run_test	"TF8"				0 	"--input=TFI7 --format=TF12"											"Neformatujeme prazdne retezce"
run_test	"TF9"				0 	"--input=TFI8 --format=TF13"											"Test negace"
run_test	"TF3"				0 	"--input=TFI2 --format=TF1"												"Html znacky jsou brany jako normalni znaky"
run_test	"TF10"			0 	"--input=TFI9 --format=TF14"											"Html znacky v textu i v reg. vyrazu"
run_test	"TF4"				0 	"--input=TFI3 --format=TF1"												"Diakritika v textu"
run_test	"TF5"				0 	"--input=TFI4 --format=TF8"												"Diakritika v textu i v reg. vyrazu"
run_test	"TF5"				0 	"--input=TFI4 --format=TF9"												"Diakritika v textu i v reg. vyrazu"
run_test	"TF11"			0 	"--input=TFI1 --format=TF1 --br"									"Aplikace tagu <br />"

echo
echo -e "${red}Testy rozsireni HTM${NC}"
echo

run_test 	"TV1"				0 	"--input=TVI1 --format=TVF1 --validate"						"Test jednoduche validace"
run_test 	"TV2"				0 	"--input=TVI2 --format=TVF2 --validate"						"Test slozitejsi validace"
run_test 	"TV3"				0 	"--input=TVI3 --format=TVF3 --validate"						"Test velmi komplikovane validace"





# <sem pridavejte nove testy>

################################################################################

color=${red}
if [ "$ok_count" = "$count" ]; then
	color=${green}
fi

echo
echo "--------------------------------------------------------------------------------"
echo -e "Proslo ${color}$ok_count${NC} testu z $count"
echo "--------------------------------------------------------------------------------"
