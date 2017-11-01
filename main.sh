#!/bin/bash

source 3d.sh

function main()
{
	echo "Running..."
	glFrustum `to -1` `to 1` `to 1` `to -1` `to 2` `to 10`
	glLoadIdentity
        toM4=$(to -4)
        toM1=$(to -1)
        to0=$(to 0)
        to1=$(to 1)
        to2=$(to 2)
        to3=$(to 3)
	for ((i=0; i<720; ++i)); do
		glTranslate $to0 $to0 $to2
		SCR_BUFF=$(clearBuff | sed 's/./|&/g;s/$/|/' | gcut --complement --output-delimiter='*' -c $(sed 's/,$//' \
                <(
                     glLine $toM1 $toM1 $to1 $to1 $toM1 $to1&
                     glLine $to1 $toM1 $to1 $to1 $to1 $to1&
                     glLine $to1 $to1 $to1 $toM1 $to1 $to1&
                     glLine $toM1 $to1 $to1 $toM1 $toM1 $to1&
                     glLine $toM1 $toM1 $to3 $to1 $toM1 $to3&

                     glLine $to1 $toM1 $to3 $to1 $to1 $to3&
		     glLine $to1 $to1 $to3 $toM1 $to1 $to3&
		     glLine $toM1 $to1 $to3 $toM1 $toM1 $to3&

		     glLine $toM1 $toM1 $to1 $toM1 $toM1 $to3&
		     glLine $to1 $toM1 $to1 $to1 $toM1 $to3&
		     glLine $to1 $to1 $to1 $to1 $to1 $to3&
		     glLine $toM1 $to1 $to1 $toM1 $to1 $to3&
                 )) | tr -d '|')

		glSwap &
		glTranslate $to0 $to0 $toM4
		glRotate $((43643578047 * $FACTOR / 100000000000)) $((87287156094 * $FACTOR / 100000000000)) $((21821789023 * $FACTOR / 100000000000)) 1
		glTranslate $to0 $to0 $to2
	done
}

main
tput cup `tput lines` 0
