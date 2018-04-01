#!/bin/bash

INDEX_FILE=$(dirname $(realpath $0))/index.tmp
BKP_DIR=/tmp/backups
TO_BKP="$1"
DATE=$(date +%m.%d.%Y_%H.%M.%S)
HISTORY_SIZE=$(( $2 ))

ARGS=2

E_BADARGS=65

if [ $# -ne "$ARGS" ]
then
  echo "error: not all parameters for the script are transferred: `basename $0`" 1>&2
  exit $E_BADARGS
else

#echo ${INDEX_FILE}
if [ ! -f ${INDEX_FILE} ]; then
        INDEX=0
else
        let INDEX=$(cat ${INDEX_FILE})+1
        if [ ${INDEX} -gt ${HISTORY_SIZE} ]; then
                INDEX=${HISTORY_SIZE}
        fi
fi

#echo INDEX: ${INDEX}

test -d ${BKP_DIR} || mkdir -p ${BKP_DIR}

if  ![ -d "${TO_BKP}" -o  -f "$TO_BKP" ]; then
        echo "Path to backup is not exists" 1>&2
        exit 1
fi

BKP_BASENAME=`echo $1 | sed "s/\//-/g;s/^.//"`

tar -czf "${BKP_DIR}/${BKP_BASENAME}_${DATE}_${INDEX}.tar.gz" -P "${TO_BKP}"

if [ ${INDEX} -ge $(( ${HISTORY_SIZE} )) ]; then
        for current_index in $(seq 1 ${HISTORY_SIZE}); do
                let prev_index=${current_index}-1
#                echo ${current_index} ${prev_index}
                        rm_file=$(find ${BKP_DIR} -maxdepth 1 -type f -name "${BKP_BASENAME}_*_${prev_index}.tar.gz")
                        current_file=$(find ${BKP_DIR} -maxdepth 1 -type f -name "${BKP_BASENAME}_*_${current_index}.tar.gz"|tail -n 1)
                        prev_file=$(echo ${current_file}|sed -r "s/_[0-9]+.tar.gz$/_${prev_index}.tar.gz/g")

#                        echo "PF: ${prev_file}"
#                        echo "CF: ${current_file}"
#                        echo "RF: ${rm_FILE}"

                        if [ -n "${current_file}" ]; then
                                rm -f "${rm_file}"
                                mv "${current_file}" "${prev_file}"
                        fi
        done
fi

echo ${INDEX} > ${INDEX_FILE}
fi
