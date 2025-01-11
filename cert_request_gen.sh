#!/usr/bin/env bash
# filename: cert_request_gen.sh
# author: @AntonenkovArt

#TODO:
#6 - написать README
#7 - Собрать дистрибутив и залить на гитхаб


showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
	case $1 in
		rsa)
			cat << EOF
Usage: rsa [ command_opts ] [ opts_args ]

RSA options:
-help                 Display help
-type dv|ov           Validation type. Required.
-declarant ip|fl|yl   Declarant type. Required for ov type, optional for dv.
-keylength 2048|4096  Keypair bit length. Optional. 256 set by default.
-count 1-100          Number of generated requests. Optional.
EOF
		;;
		gost)
			cat << EOF
Usage: gost [ command_opts ] [ opts_args ]

GOST options:
-help                Display help
-type dv|ov          Validation type. Required.
-declarant ip|fl|yl  Declarant type. Required for ov type, optional for dv.
-keylength 256|512	 Keypair bit length. Optional. 256 set by default.
-paramset XA|A|B     Keypair paramset. Optional. XA is default and the only variant for 256 keypair, A|B - for 512 keypair (A by default).
-count 1-100          Number of generated requests. Optional.
EOF
		;;
		*)
			cat << EOF  
Usage: ./cert_request_gen.sh command [ command_opts ] [ opts_args ]
Note: Check filepaths.conf to see utility paths.

Standard commands:
rsa         Generate certificate request using RSA encryption
gost        Generate certificate request using GOST encryption
help        Display help
version     Display version
EOF
		;;
	esac
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

CheckFileExistance () {
	file_name="${1}"
	if [[ ! -f "${file_name}" ]]; then
		echo -e "ERROR: Could not find the file \"${file_name}\""
		exit 1
	fi
}


### MAIN
#Get script name and check filepaths.conf existance. Using filepaths config.
scrip_name=$(basename $0)
filepaths="filepaths.conf"
CheckFileExistance "${filepaths}"
. "${filepaths}"

#Set first argument (using it as command)
argument=$1
#Check if there is no arguments
if [[ ! $argument ]]; then
	echo "ERROR: No arguments were provided"
	exit 1
fi

#Declaring asociative array (like dictionary) with default values
declare -A required_options
required_options["keylength"]="null"
required_options["type"]="null"
required_options["count"]="0"
not_specified="false"

#Check first argument and select action for it
case "$argument" in
	rsa)
	request_template="rsa_"
	request_command='openssl req -new -newkey rsa:${required_options["keylength"]} -sha256 -keyout "${OUTPUT_DIR}"/"${request_name}".key -config "${request_template}".template -out  "${OUTPUT_DIR}"/"${request_name}".csr -nodes'
	required_options["keylength"]="2048"
	;;
	gost)
	request_template="gost_"
	request_command='openssl req -new -newkey gost2012_${required_options["keylength"]} -pkeyopt paramset:${required_options["paramset"]} -keyout "${OUTPUT_DIR}"/"${request_name}".key -config "${request_template}".template -out  "${OUTPUT_DIR}"/"${request_name}".p10 -outform DER -nodes'
	required_options["keylength"]="256"
	;;
	help)
	showHelp
	exit 0
	;;
	version)
	echo "cert_request_gen.sh version: 1.0.0"
	exit 0
	;;
	*)
	echo "ERROR: Unknown argument"
	exit 1
	;;
esac
shift

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,type:,declarant:,paramset:,count:,keylength:" -o "" -a -- "$@" 2>&1) 
if [[ ! $? -eq 0 ]]; then
	echo "ERROR: ${options}"
	exit 1
fi

#Taking remain arguments after getopt processing
arguments=$(echo $options | rev | awk -F '--' '{print $1}' | rev)
if [[ $arguments ]]; then
	echo "ERROR: Too many arguments were provided"
	exit 1
fi

# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters 
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

#Check for duplicate options
duplicate_options=$(echo $options | tr " " "\n" | sort | uniq -c | grep -v '^ *1 ')
if [[ $duplicate_options ]]; then
	echo "ERROR: Duplicate options found were provided"
	echo $duplicate_options | sed 's/[0-9]//g'
	exit 1
fi

#Processing main options for command (first argument)
while true
do
	case "$1" in
		--help) 
			    showHelp "${argument}"
			    exit 0
		    ;;
		--type)
			shift
			case $1 in
				dv)
					required_options["type"]="$1"
				;;
				ov)
					required_options["type"]="$1"
				;;
				*)
					echo "ERROR: Wrong validation type"
					exit 1
				;;
			esac
	    ;;
		--declarant)
			shift
			case $1 in
				ip)
					required_options["declarant"]="$1"
				;;
				fl)
					required_options["declarant"]="$1"
				;;
				yl)
					required_options["declarant"]="$1"
				;;
				*)
					echo "ERROR: Wrong declarant type"
					exit 1
				;;
			esac
	    ;;
		--keylength)
			shift
			if [ "${argument}" == "rsa" ]; then
				case "$1" in
					2048)
						required_options["keylength"]="$1"
					;;
					4096)
						required_options["keylength"]="$1"
					;;
					*)
						echo "ERROR: Wrong keylength"
						exit 1
					;;
				esac
			elif [ "${argument}" == "gost" ]; then
				case "$1" in
					256)
						required_options["keylength"]="$1"
					;;
					512)
						required_options["keylength"]="$1"
					;;
					*)
						echo "ERROR: Wrong keylength"
						exit 1
					;;
				esac
			fi
	    ;;
		--paramset)
		    shift
		    if [ "${argument}" == "rsa" ]; then
				echo "ERROR: Cannot use paramset option with RSA encryption"
				exit 1
			elif [ "${argument}" == "gost" ]; then
				case "$1" in
					A)
						required_options["paramset"]="$1"
					;;
					B)
						required_options["paramset"]="$1"
					;;
					XA)
						required_options["paramset"]="$1"
					;;
					*)
						echo "ERROR: Wrong paramset"
						exit 1
					;;
				esac
			fi
	    ;;
		--count)
		    shift
			if ! [[ $1 =~ ^[0-9]+$ ]] ; then
				echo "ERROR: Count value must be integer"
				exit 1
			fi
		    if [ "${1}" -gt 0 ] && [ "${1}" -lt 101 ]; then
		    	required_options["count"]=$(("$1"-1))
		    else
		    	echo "ERROR: Count value must be >= 1 and <= 100"
		    	exit 1
		    fi
	    ;;
		--)
		    shift
	    	break
	    ;;
		*)
			echo "ERROR: Unknown option was provided"
			exit 1
		;;
	esac
	shift
done

#Checking keylength and paramset compatibility
case "${required_options["keylength"]}" in 
	256)
		#проверка - если не указан парамсет, указать дефолтный
		if [ ! -v required_options["paramset"] ]; then
			required_options["paramset"]="XA"
		fi
		if [ "${required_options["paramset"]}" != "XA" ]; then
			echo "ERROR: Cannot use paramset ${required_options["paramset"]} with keylength ${required_options["keylength"]}"
			exit 1
		fi
	;;
	512)
		#проверка - если не указан парамсет, указать дефолтный
		if [ ! -v required_options["paramset"] ]; then
			required_options["paramset"]="A"
		fi
		if [ "${required_options["paramset"]}" != "A" ] && [ "${required_options["paramset"]}" != "B" ]; then
			echo "ERROR: Cannot use paramset ${required_options["paramset"]} with keylength ${required_options["keylength"]}"
			exit 1
		fi
	;;
esac

#Checking for required null options
for required_option in "${!required_options[@]}"; do
	if [ "${required_options[${required_option}]}" == "null" ]; then
		not_specified="true"
		echo "ERROR: Required option ${required_option} is not specified"
	fi
done

#Exit if there are null options
if [ "${not_specified}" == "true" ]; then
	exit 1
fi

#Checking type and declarant compatibility 
#Connecting type and declarant for template_name
case "${required_options["type"]}" in
	dv)
		type_declarant="dv"
	;;
	ov)
		if [ ! -v required_options["declarant"] ]; then
			echo "ERROR: Cannot use ov type without declarant"
			exit 1
		fi
		type_declarant="ov_${required_options["declarant"]}"
	;;
esac

#Forming template_name
request_template+="${type_declarant}"
echo -e "Using template ${request_template}.template\n"

#Get last request number by template name
last_request_number=$(find "${OUTPUT_DIR}" -name "${request_template}_*" | sort -V | rev | cut -d "." -f2 | rev | tail -1 | grep -Eo '[0-9]+')

#New request number
request_number=$((${last_request_number}+1))

#Generating requests using request_name and request_command
for (( counter=0; counter<="${required_options["count"]}"; counter++ )); do
	new_request_number=$((${request_number}+${counter}))
	request_name="${request_template}_${new_request_number}"
	echo "Generating request ${request_name}"
	eval $request_command
done

echo -e "\nDone"
exit 0
