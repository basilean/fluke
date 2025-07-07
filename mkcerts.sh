#!/bin/bash
#
# Fluke (https://github.com/basilean/fluke)
# Andres Basile
# GNU/GPL v3
#

CLIENTS="${CLIENTS:-blackbox1 blackbox2}"

BASEDN="/O=BasileSoft/OU=Fluke"
SERVERS="server proxy"
TEMPDIR="/tmp/certs"

function mkconf() {
	echo "[req]
distinguished_name=req_dn
[req_dn]
[v3_ca]
basicConstraints=CA:TRUE"
}

function mkext() {
	echo "[crt]
basicConstraints=CA:FALSE
subjectAltName=DNS:${1}"
}

function mkcert() {
	SUBJECT=${1}
	KEY=${2}
	CERT=${3}
	CA_KEY=${4}
	CA_CERT=${5}
	openssl genrsa -out ${KEY} 4096
	openssl req -new -nodes \
		-subj "${SUBJECT}" \
		-key ${KEY} \
		-out "${TEMPDIR}/temp.csr"
	openssl x509 -req -days 36500 \
		-CA ${CA_CERT} \
		-CAkey ${CA_KEY} \
		-CAcreateserial \
		-extfile <(mkext ${1}) \
		-extensions crt \
		-in "${TEMPDIR}/temp.csr" \
		-out ${CERT}
}

function mkca() {
	SUBJECT=${1}
	KEY=${2}
	CERT=${3}
	openssl genrsa -out ${KEY} 4096
	openssl req -new -x509 -nodes -days 36500 \
		-subj "${SUBJECT}" \
		-config <(mkconf) \
		-extensions v3_ca \
		-key ${KEY} \
		-out ${CERT}
}

function mkcerts() {
	TARGET=${1}
	LIST=${2}
	for CN in ${LIST}
	do
		mkdir "${TARGET}/${CN}"
		cp "${TEMPDIR}/ca.crt" "${TARGET}/${CN}/ca.crt"
		mkcert "${BASEDN}/CN=${CN}" \
			"${TARGET}/${CN}/tls.key" "${TARGET}/${CN}/tls.crt" \
			"${TEMPDIR}/ca.key" "${TEMPDIR}/ca.crt"
	done
}

if [[ -e ${TEMPDIR} ]]
then
	printf "Remove temp dir: "%s" and try again.\n$ rm -r "%s"\n" ${TEMPDIR} ${TEMPDIR}
	exit 1
fi

mkdir ${TEMPDIR}
mkca "${BASEDN}/CN=CA" "${TEMPDIR}/ca.key" "${TEMPDIR}/ca.crt"
mkcerts "nginx" "${SERVERS}"
mkcerts "blackbox" "${CLIENTS}"

mkdir "nginx/users"
NEWPASS=$(openssl rand -base64 6)
HASHPASS=$(openssl passwd -apr1 ${NEWPASS})
printf "admin:${HASHPASS}\n" > "nginx/users/.htpasswd"
printf "${NEWPASS}\n" > "nginx/users/READ_AND_REMOVE.txt"
