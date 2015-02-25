#!/bin/bash

SCRIPT="../ipp-syn/syn.php"
INTERPRETER="php"

if [ `basename "$PWD"` != "ipp-syn-test" ]; then
	cd "../ipp-syn-test"
	if [ `basename "$PWD"` != "ipp-syn-test" ]; then
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

	printf ""|$INTERPRETER $SCRIPT $3 1> "test.out" 2> "err.out"
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
		((ok_count++))
	else
		echo -e "[ ${red}FAIL${NC} ]"
		echo "$INTERPRETER" "$SCRIPT" "$3"
		cat "err.out"
		echo "Exit code: $exit_code"
		printf "%s" "$diffout"
		echo
	fi
	rm "test.out"
	rm "err.out"
}

function check_ref_test {
	((count++))
	if [ "$1" -lt "10" ]; then
		num="0$1"
	else
		num="$1"
	fi


	printf ">>> %-10s %-56s " "RefTest$1" ""
	if [ -f test$num.txt ]; then
		diffOut="Diffout\n`diff "ref-st/test$num.out" "ref-out/test$num.out"`\n"
		retOut=$?
	else
		retOut="0"
	fi
	diffRet="DiffRet\n`diff ref-st/test$num'.!!!' ref-out/test$num'.!!!'`\n"
	retRet=$?
	if [ "$retOut" = "0" ] && [ "$retRet" = "0" ]; then
		echo -e "[  ${green}OK${NC}  ]"
		((ok_count++))
	else
		echo -e "[ ${red}FAIL${NC} ]"
		tail ref-st/test$num.err
		printf "%s" "$diffRet"
		echo
	fi
}

################################################################################

echo
echo
echo -e "\t\t\t\t\t${green}IPP1 TESTY${NC}"

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
run_test	""					4 	"--input=TFI11 --format=TF16"											"FS reg. vyraz chybi zavorka"
#run_test	""					4 	"--input=TFI11 --format=TF17"											"FS reg. a.*"

echo
echo -e "${green}Testy spravneho formatovani${NC}"
echo

run_test	"TF6"				0 	"--input=TFI5 --format=TF10"											"Jednoduche formatovani"
run_test	"TF7"				0 	"--input=TFI6 --format=TF11"											"Aplikovani tagu ve spravnem poradi"
run_test	"TF8"				0 	"--input=TFI7 --format=TF12"											"Neformatujeme prazdne retezce"
run_test	"TF9"				0 	"--input=TFI8 --format=TF13"											"Test negace"
run_test	"TF14"			0 	"--input=TFI10 --format=TF15"											"Test negace zavorky"

#toto se resilo na foru, ale stale mi to neni uplne jasne
run_test	"TF3"				0 	"--input=TFI2 --format=TF1"												"Html znacky jsou brany jako normalni znaky"
run_test	"TF10"			0 	"--input=TFI9 --format=TF14"											"Html znacky v textu i v reg. vyrazu"

run_test	"TF4"				0 	"--input=TFI3 --format=TF1"												"Diakritika v textu"
run_test	"TF5"				0 	"--input=TFI4 --format=TF8"												"Diakritika v textu i v reg. vyrazu"
run_test	"TF5"				0 	"--input=TFI4 --format=TF9"												"Diakritika v textu i v reg. vyrazu"
run_test	"TF11"			0 	"--input=TFI1 --format=TF1 --br"									"Aplikace tagu <br />"

echo
echo -e "${green}Testy slozitejsich prikladu${NC}"
echo

run_test	"TFC1"			0 	"--input=TFCI1 --format=TFCF1 --br"								"Hlavickovy soubor"

#Toto je opravdu narocny test, ale odhalil jsem na nem nekolik chyb
#Je to hodne osekany math.h, aby vyhodnocovani netrvalu pul hodiny
run_test	"TFC2"			0 	"--input=TFCI2 --format=TFCF2 --br"								"Slozity hlavickovy soubor"



echo
echo -e "${red}Testy rozsireni HTM${NC}"
echo


run_test 	"TV1"				0 	"--input=TVI1 --format=TVF1 --validate"						"Test jednoduche validace"
run_test 	"TV2"				0 	"--input=TVI2 --format=TVF2 --validate"						"Test slozitejsi validace"

#naprosto netusim, jestli je tenhle vystup spravne, ale tagy se nekrizi - to jsem overoval
run_test 	"TV3"				0 	"--input=TVI3 --format=TVF3 --validate"						"Test velmi komplikovane validace"

run_test 	"TV4"				0   "--input=TVI4 --format=TVF4 --escape"							"Test escapovani"
run_test 	"TV5"				0   "--input=TVI5 --format=TVF5 --escape --validate"	"Test validace i escapovani"


# cesty ke vstupním a výstupním souborům
LOCAL_IN_PATH="" # (simple relative path)
LOCAL_IN_PATH2="" #Alternative 1 (primitive relative path)
LOCAL_IN_PATH3="" #Alternative 2 (absolute path)
LOCAL_OUT_PATH="ref-st/" # (simple relative path)
LOCAL_OUT_PATH2="ref-st/" #Alternative 1 (primitive relative path)
LOCAL_OUT_PATH3="ref-st/" #Alternative 2 (absolute path)
# cesta pro ukládání chybového výstupu studentského skriptu
LOG_PATH="ref-st/"

if [ ! -d "ref-st" ]; then
	mkdir "ref-st"
fi

# test01: Argument error; Expected output: test01.out; Expected return code: 1
$INTERPRETER $SCRIPT --error 2> ${LOG_PATH}test01.err
echo -n $? > ${LOCAL_OUT_PATH}test01.!!!

# test02: Input error; Expected output: test02.out; Expected return code: 2
$INTERPRETER $SCRIPT --input=nonexistent --output=${LOCAL_OUT_PATH3}test02.out 2> ${LOG_PATH}test02.err
echo -n $? > ${LOCAL_OUT_PATH}test02.!!!

# test03: Output error; Expected output: test03.out; Expected return code: 3
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}empty --output=nonexistent/${LOCAL_OUT_PATH2}test03.out 2> ${LOG_PATH}test03.err
echo -n $? > ${LOCAL_OUT_PATH}test03.!!!

# test04: Format table error - nonexistent parameter; Expected output: test04.out; Expected return code: 4
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}empty --output=${LOCAL_OUT_PATH}test04.out --format=error-parameter.fmt 2> ${LOG_PATH}test04.err
echo -n $? > ${LOCAL_OUT_PATH}test04.!!!

# test05: Format table error - size; Expected output: test05.out; Expected return code: 4
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH}empty --output=${LOCAL_OUT_PATH3}test05.out --format=error-size.fmt 2> ${LOG_PATH}test05.err
echo -n $? > ${LOCAL_OUT_PATH}test05.!!!

# test06: Format table error - color; Expected output: test06.out; Expected return code: 4
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}empty --output=${LOCAL_OUT_PATH}test06.out --format=error-color.fmt 2> ${LOG_PATH}test06.err
echo -n $? > ${LOCAL_OUT_PATH}test06.!!!

# test07: Format table error - RE syntax; Expected output: test07.out; Expected return code: 4
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}empty --output=${LOCAL_OUT_PATH3}test07.out --format=error-re.fmt 2> ${LOG_PATH}test07.err
echo -n $? > ${LOCAL_OUT_PATH}test07.!!!

# test08: Empty files; Expected output: test08.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}empty --output=${LOCAL_OUT_PATH3}test08.out --format=empty 2> ${LOG_PATH}test08.err
echo -n $? > ${LOCAL_OUT_PATH}test08.!!!

# test09: Format parameters; Expected output: test09.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}basic-parameter.in --output=${LOCAL_OUT_PATH3}test09.out --format=basic-parameter.fmt 2> ${LOG_PATH}test09.err
echo -n $? > ${LOCAL_OUT_PATH}test09.!!!

# test10: Argument swap; Expected output: test10.out; Expected return code: 0
$INTERPRETER $SCRIPT --format=basic-parameter.fmt --output=${LOCAL_OUT_PATH3}test10.out --input=${LOCAL_IN_PATH}basic-parameter.in 2> ${LOG_PATH}test10.err
echo -n $? > ${LOCAL_OUT_PATH}test10.!!!

# test11: Standard input/output; Expected output: test11.out; Expected return code: 0
$INTERPRETER $SCRIPT --format=basic-parameter.fmt >${LOCAL_OUT_PATH3}test11.out <${LOCAL_IN_PATH}basic-parameter.in 2> ${LOG_PATH}test11.err
echo -n $? > ${LOCAL_OUT_PATH}test11.!!!

# test12: Basic regular expressions; Expected output: test12.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}basic-re.in --output=${LOCAL_OUT_PATH3}test12.out --format=basic-re.fmt 2> ${LOG_PATH}test12.err
echo -n $? > ${LOCAL_OUT_PATH}test12.!!!

# test13: Special regular expressions; Expected output: test13.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}special-re.in --output=${LOCAL_OUT_PATH3}test13.out --format=special-re.fmt 2> ${LOG_PATH}test13.err
echo -n $? > ${LOCAL_OUT_PATH}test13.!!!

# test14: Special RE - symbols; Expected output: test14.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}special-symbols.in --output=${LOCAL_OUT_PATH2}test14.out --format=special-symbols.fmt 2> ${LOG_PATH}test14.err
echo -n $? > ${LOCAL_OUT_PATH}test14.!!!

# test15: Negation; Expected output: test15.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH}negation.in --output=${LOCAL_OUT_PATH3}test15.out --format=negation.fmt 2> ${LOG_PATH}test15.err
echo -n $? > ${LOCAL_OUT_PATH}test15.!!!

# test16: Multiple format parameters; Expected output: test16.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}multiple.in --output=${LOCAL_OUT_PATH3}test16.out --format=multiple.fmt 2> ${LOG_PATH}test16.err
echo -n $? > ${LOCAL_OUT_PATH}test16.!!!

# test17: Spaces/tabs in format parameters; Expected output: test17.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}multiple.in --output=${LOCAL_OUT_PATH3}test17.out --format=spaces.fmt 2> ${LOG_PATH}test17.err
echo -n $? > ${LOCAL_OUT_PATH}test17.!!!

# test18: Line break tag; Expected output: test18.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}newlines.in --output=${LOCAL_OUT_PATH}test18.out --format=empty --br 2> ${LOG_PATH}test18.err
echo -n $? > ${LOCAL_OUT_PATH}test18.!!!

# test19: Overlap; Expected output: test19.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}overlap.in --output=${LOCAL_OUT_PATH3}test19.out --format=overlap.fmt 2> ${LOG_PATH}test19.err
echo -n $? > ${LOCAL_OUT_PATH}test19.!!!

# test20: Perl RE; Expected output: test20.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH3}special-symbols.in --output=${LOCAL_OUT_PATH3}test20.out --format=re.fmt 2> ${LOG_PATH}test20.err
echo -n $? > ${LOCAL_OUT_PATH}test20.!!!

# test21: Example; Expected output: test21.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}example.in --br --format=example.fmt > ${LOCAL_OUT_PATH3}test21.out 2> ${LOG_PATH}test21.err
echo -n $? > ${LOCAL_OUT_PATH}test21.!!!

# test22: Simple C program; Expected output: test22.out; Expected return code: 0
$INTERPRETER $SCRIPT --input=${LOCAL_IN_PATH2}cprog.c --br --format=c.fmt > ${LOCAL_OUT_PATH2}test22.out 2> ${LOG_PATH}test22.err
echo -n $? > ${LOCAL_OUT_PATH}test22.!!!



for i in {1..22}
do
	check_ref_test $i
done



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
