#!/bin/bash

FACTOR=10000

function to
{
	echo $(($1 * $FACTOR))
}

source sincos.sh
source vec.sh
source mat.sh

WIDTH=
HEIGHT=
COL=
LINE=
HALF_WIDTH=
HALF_HEIGHT=
SCR_BUFF=
BUFF_SIZE=
function glInit()
{
	COL=$(tput cols)
	LINE=$(tput lines)
	WIDTH=$(($FACTOR * $COL))
	HEIGHT=$(($FACTOR * $LINE))
	HALF_WIDTH=$(($WIDTH / 2))
	HALF_HEIGHT=$(($HEIGHT / 2))
	HALF_COL=$(($COL / 2))
	HALF_LINE=$(($LINE / 2))
	BUFF_SIZE=$(($COL * $LINE))
}
glInit
function glClear()
{
	SCR_BUFF=$(head -c $BUFF_SIZE < /dev/zero | tr '\0' '_')
}

function clearBuff()
{
	head -c $BUFF_SIZE < /dev/zero | tr '\0' '_'
}

function glSwap()
{
	tput clear
	tput cup 0 0
	echo -n $SCR_BUFF | tr '_' ' '
}

MODEL_MAT=
PROJ_MAT=
mIdent MODEL_MAT
mIdent PROJ_MAT

function glLoadIdentity() {
	mIdent MODEL_MAT
}

function glTranslate()
{
	MODEL_MAT=(MAT $(mMulFast MAT $(mTransFast $1 $2 $3) ${MODEL_MAT[@]}))
}
function glScale()
{
	MODEL_MAT=(MAT $(mMulFast MAT $(mScaleFast $1 $2 $3) ${MODEL_MAT[@]}))
}
function glRotate()
{
	v=
	mRotate $1 $2 $3 $4 v
	MODEL_MAT=(MAT $(mMulFast ${v[@]} ${MODEL_MAT[@]}))
}

function glFrustum()
{
	mFrustum $1 $2 $3 $4 $5 $6 PROJ_MAT
}

function gToScreen()
{
	in=($(eval echo $(eval echo "\$\{$1[@]\}")))
	eval $2="$((( ${in[1]} * $HALF_WIDTH  / ${in[4]} + $HALF_WIDTH ) / $FACTOR ))"
	eval $3="$((( ${in[2]} * $HALF_HEIGHT / ${in[4]} + $HALF_HEIGHT ) / $FACTOR ))"
}

function gToScreenArg()
{
    echo $((( $1 * $HALF_WIDTH  / $4 + $HALF_WIDTH ) / $FACTOR )) $((( $2 * $HALF_HEIGHT / $4 + $HALF_HEIGHT ) / $FACTOR ))
}

function gLine()
{
	if(($1 < $3));then
		dx=$(($3 - $1))
		sx=1
	else
		dx=$(($1 - $3))
		sx=-1
	fi
	if(($2 < $4));then
		dy=$(($4 - $2))
		sy=1
	else
		dy=$(($2 - $4))
		sy=-1
	fi
	x=$1
	y=$2
	err=$(($dx - $dy))
        while [[ $x -ne $3 || $y -ne $4 ]]; do
            echo -n $((2*($y * $COL + $x + 1)))','
            e2=$((2 * $err))
            if [[ $e2 -gt -$dy ]]; then
                ((err -= $dy))
                ((x += $sx))
            fi
            if [[ $e2 -lt $dx ]]; then
                ((err += $dx))
                ((y += $sy))
	    fi
	done
}




function glLine()
{
        pm_MAT=$(mMulFast ${PROJ_MAT[@]} ${MODEL_MAT[@]})
        gLine $(gToScreenArg $(mvMulFast MAT $pm_MAT VEC $1 $2 $3 $FACTOR)) $(gToScreenArg $(mvMulFast MAT $pm_MAT VEC $4 $5 $6 $FACTOR))
}

