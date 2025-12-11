#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
     	tput cnorm && exit 1
}


#Ctrl+c
trap ctrl_c INT

#variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
				
	echo -e "\n${yellowColour}[+]${endColour}${grayColour}Uso:${endColour}\n"
	echo -e "\t${purpleColour}u)${endColour}${grayColour}Descargar o actualizar archivos necesarios${endColour}"
	echo -e "\t${purpleColour}m)${endColour}${grayColour}Buscar por un nombre de maquina${endColour}"	
	echo -e "\t${purpleColour}i)${endColour}${grayColour}Buscar por direccion IP${endColour}"
	echo -e "\t${purpleColour}y)${endColour}${grayColour}Obtener enlace link de la resolucion de maquina en youtube${endColour}"
	echo -e "\t${purpleColour}d)${endColour}${grayColour}Buscar por difilcultad de una maquina${endColour}"
	echo -e "\t${purpleColour}o)${endColour}${grayColour}Buscar por el sistema operativo${endColour}"
	echo -e "\t${purpleColour}s)${endColour}${grayColour}Buscar por skills${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${grayColour}Mostrar este panel de ayuda${endColour}\n"
	


}




function updateFiles(){
	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Descargando archivo necesarios...${endColour}"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Todos los archivos han sido descargados${endColour}\n"
        	tput cnorm
	else
		tput civis
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Comprobando si hay actualizaciones pendientes${endColour}\n"
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "${yellowColour}[+]${endColour}${grayColour}No se han detectado actualizaciones, lo tienes todo al dia :)${endColour}\n"
			rm bundle_temp.js
		else
			echo -e  "${yellowColour}[+]${endColour}${grayColour}Se han encontrado actualizaciones${endColour}\n"
			sleep 1
			rm bundle.js && mv bundle_temp.js bundle.js

			echo -e "${yellowColour}[+]${endColour}${grayColour}Los archivos han sido actualizados${endColour}\n"
		fi
		
		tput cnorm
	fi
}
    
function searchMachine(){
	machineName="$1"

	machinename_checker="$(cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

	if [ "$machinename_checker" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Listando las propiedas de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
		cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
	else
		echo -e "\n${redColour}[!] La maquina indicada no existe${endColour}\n"
	fi

	 
}


function searchIP(){
	ipAddress=$1
	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name" | awk '{print $2}' | tr -d '"' | tr -d ',')"
	if [ "$machineName" ]; then
	echo -e "\n${yellowColour}[+]${endColour}${grayColour}La maquina correspondiente para la ip es${endColour} ${blueColour}$ipAddress${endColour} ${grayColour}es${endColour} ${redColour}$machineName${endColour}\n"
	else
		echo -e "\n${redColour}[!] La direccion IP indicada no existe${endColour}\n"
	fi

}


function getYoutubeLink(){

	machineName="$1"

	youtubeLink="$(cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

	if [ $youtubeLink ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El enlace para la maquina${endColour} ${blueColour}$machineName${endColour} ${grayColour}es el siguiente:${endColour} ${blueColour}$youtubeLink${endColour}\n"
	else
		echo -e "\n${redColour}[!]La maquina proporcionada no existe${endColour}\n"
	fi
	
}

function getMachinesDiffilculty(){
	diffilculty="$1"
	results_checked="$(cat bundle.js | grep "dificultad: \"$diffilculty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$results_checked" ]; then
		cat bundle.js | grep "dificultad: \"$diffilculty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
		echo -e "${yellowColour}[+]${endColour} ${grayColour}Representando las maquinas que posee un nivel de dificultad${endColour} ${blueColour}$diffilculty${endColour}"

	else
		echo -e "${redColour}[!]La difilcultad no existe${endColour}"
	fi
}

function getOSMachines(){
 	os="$1"
 	os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:"| awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	
	if [ "$os_results" ]; then
		echo -e "${yellowColour}[+]${endColour} ${grayColour}Mostrando las maquinas del sistema operativo${endColour} ${blueColour}$os${endColour}"
		cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:"| awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "${redColour}[!] Sistema operativo incorrectoa${endColour}"
	fi
}


function getOSdiffilcultyMachines(){
	diffilculty="$1"
	os="$2"

	check_results="$(cat bundle.js | grep "so: \"$os\""  -C 4 | grep "dificultad: \"$diffilculty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk '{print $2}' | column)"
	
	if [ "$check_results" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Resultado de la busqueda por difilcultad${endColour} ${blueColour}$diffilculty${endColour} ${grayColour}y sistema operativo${endColour} ${blueColour}$os${endColour}\n"
		cat bundle.js | grep "so: \"$os\""  -C 4 | grep "dificultad: \"$diffilculty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk '{print $2}' | column
	else
		echo -e "\n${redColour}[!] Error difilcultad o sistema operativo incorrecto${endColour}\n"
	fi


}


function getMachinesSkills(){
	skills="$1"
	check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | tr -d '"' | tr -d ',' | awk '{print $2}' | column)"

	if [ "$check_skill" ]; then
		echo -e "${yellowColour}[+]${endColour} ${grayColour}Resultado de maquinas con skill en${endColour} ${redColour}$skills${endColour}"
		cat bundle.js | grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | tr -d '"' | tr -d ',' | awk '{print $2}' | column
	else
		echo -e "\n${redColour}[!] Skills no encontrado${endColour}\n"
	fi

}

#Indicadores
declare -i parameter_counter=0

#chivatos

declare -i chivato_diffilculty=0
declare -i chivato_os=0


while getopts "m:hi:y:ud:o:s:" arg; do
	case $arg in
	  m) machineName="$OPTARG"; let parameter_counter+=1;;
	  u) let parameter_counter+=2;;
	  i) ipAddress="$OPTARG"; let parameter_counter+=3;;
	  y) machineName="$OPTARG"; let parameter_counter+=4;;
	  d) diffilculty="$OPTARG"; chivato_diffilculty=1; let parameter_counter+=5;;
	  o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
	  s) skills="$OPTARG"; let parameter_counter+=7;;
	  h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDiffilculty $diffilculty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
	getMachinesSkills "$skills"
elif [ $chivato_diffilculty -eq 1  ] && [ $chivato_os -eq 1 ] ; then
	getOSdiffilcultyMachines $diffilculty $os
else
	helpPanel
fi
