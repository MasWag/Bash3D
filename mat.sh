#! /bin/bash

function mAssert() {
	v=$(eval echo "\$\{$1[@]\}")
	all=$(eval echo "$v")
	v=$(eval echo "\$\{$1[0]\}")
	name=$(eval echo "$v")
	v=$(eval echo "\$\{#$1[@]\}")
	len=$(eval echo "$v")
	if [[ "${name}" != "MAT" ]]; then
		echo \( ${all} \)is not Matrix: $name
		exit -1
	fi
	if [[ $len -ne 17 ]]; then
		echo \( ${all} \) not Matrix: length: $len
		exit -1
	fi
}

function mZero()
{
	v1=(MAT\
			0 0 0 0\
			0 0 0 0\
			0 0 0 0\
			0 0 0 0\
			)
	eval "$1=(${v1[@]})"
}
function mIdent()
{
	v1=(MAT\
			$FACTOR 0 0 0\
			0 $FACTOR 0 0\
			0 0 $FACTOR 0\
			0 0 0 $FACTOR\
			)
	eval "$1=(${v1[@]})"
}

function mScale()
{
	v1=(MAT\
			$1 0 0 0\
			0 $2 0 0\
			0 0 $3 0\
			0 0 0 $FACTOR\
			)
	eval "$4=(${v1[@]})"
}

function mScaleFast()
{
    echo $1 0 0 0 0 $2 0 0 0 0 $3 0 0 0 0 $FACTOR
}

function mTrans()
{
	v1=(MAT\
			$FACTOR 0 0 $1\
			0 $FACTOR 0 $2\
			0 0 $FACTOR $3\
			0 0 0 $FACTOR\
			)
	eval "$4=(${v1[@]})"
}

function mTransFast() {
    echo $FACTOR 0 0 $1 0 $FACTOR 0 $2 0 0 $FACTOR $3 0 0 0 $FACTOR
}

function mRotate()
{
	s=${SIN[$4]}
	c=${COS[$4]}
        SCFACTORMc=$(($SINCOS_FACTOR - $c))
        cFACTOR2=$(($c * $FACTOR * $FACTOR))
        s1FACTOR=$(($s * $1 * $FACTOR))
        s2FACTOR=$(($s * $2 * $FACTOR))
        s3FACTOR=$(($s * $3 * $FACTOR))
eval <<- EOF $5=\(MAT \
$(( ( $1 * $1 * $SCFACTORMc + ( $cFACTOR2 ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $1 * $2 * $SCFACTORMc - ( $s3FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $1 * $3 * $SCFACTORMc + ( $s2FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
0 \
$(( ( $2 * $1 * $SCFACTORMc + ( $s3FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $2 * $2 * $SCFACTORMc + ( $cFACTOR2 ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $2 * $3 * $SCFACTORMc - ( $s1FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
0 \
$(( ( $1 * $3 * $SCFACTORMc - ( $s2FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $2 * $3 * $SCFACTORMc + ( $s1FACTOR ) ) / $FACTOR / $SINCOS_FACTOR )) \
$(( ( $3 * $3 * $SCFACTORMc + ( $cFACTOR2 ) ) / $FACTOR / $SINCOS_FACTOR )) \
0 \
0 0 0 $FACTOR \)
EOF
}

#float l 1
#float r 2
#float b 3
#float t 4
#float n 5
#float f 6
function mFrustum ()
{
eval <<- EOF $7=\(MAT \
$(( 2 * $5 * $FACTOR / ( $2 - $1 ) )) \
0 \
$(( ( $2 + $1 ) * $FACTOR / ( $2 - $1 ) )) \
0 \
\
0 \
$(( 2 * $5 * $FACTOR / ( $4 - $3 ) )) \
$(( ( $4 + $3 ) * $FACTOR / ( $4 - $3 ) )) \
0 \
\
0 \
0 \
$(( -1 * ( $5 + $6 ) * $FACTOR / ( $6 - $5 ) )) \
$(( 2 * $6 * $5 / ( $6 - $5 ) )) \
0 0 -$FACTOR 0\)
EOF
}

function mIndex() {
#	i:$1
#	j:$2
	echo $((1 + $1 * 4 + $2))
}

function mGet() {
	in1=($(eval echo $(eval echo "$\{$1[@]\}")))
	mAssert in1
	index=$(mIndex $2 $3)
	echo ${in1[$index]}
}
function mSet() {
	in1=($(eval echo $(eval echo "$\{$1[@]\}")))
	mAssert in1
	index=$(mIndex $2 $3)
	in1[$index]=$4
	eval "$5=(${in1[@]})"
}

function mvMul()
{
	in1=($(eval echo $(eval echo "$\{$1[@]\}")))
	in2=($(eval echo $(eval echo "$\{$2[@]\}")))
	mAssert in1
	vAssert in2
eval <<- EOF $3=\(VEC \
$(( ( ${in1[1]} * ${in2[1]} + ${in1[2]} * ${in2[2]} + ${in1[3]} * ${in2[3]} + ${in1[4]} * ${in2[4]} ) / $FACTOR )) \
$(( ( ${in1[5]} * ${in2[1]} + ${in1[6]} * ${in2[2]} + ${in1[7]} * ${in2[3]} + ${in1[8]} * ${in2[4]} ) / $FACTOR )) \
$(( ( ${in1[9]} * ${in2[1]} + ${in1[10]} * ${in2[2]} + ${in1[11]} * ${in2[3]} + ${in1[12]} * ${in2[4]} ) / $FACTOR )) \
$(( ( ${in1[13]} * ${in2[1]} + ${in1[14]} * ${in2[2]} + ${in1[15]} * ${in2[3]} + ${in1[16]} * ${in2[4]} ) / $FACTOR ))\)
EOF

}

function mvMulFast()
{
    shift
    cat <<- EOF 
$(( ( ${1} * ${18} + ${2} * ${19} + ${3} * ${20} + ${4} * ${21} ) / $FACTOR )) \
$(( ( ${5} * ${18} + ${6} * ${19} + ${7} * ${20} + ${8} * ${21} ) / $FACTOR )) \
$(( ( ${9} * ${18} + ${10} * ${19} + ${11} * ${20} + ${12} * ${21} ) / $FACTOR )) \
$(( ( ${13} * ${18} + ${14} * ${19} + ${15} * ${20} + ${16} * ${21} ) / $FACTOR ))
EOF
}

function mMul() {
	in1=($(eval echo $(eval echo "$\{$1[@]\}")))
	in2=($(eval echo $(eval echo "$\{$2[@]\}")))
	mAssert in1
	mAssert in2
	eval <<-EOF $3=\(MAT \
$(( ( ${in1[1]} * ${in2[1]} + ${in1[2]} * ${in2[5]} + ${in1[3]} * ${in2[9]} + ${in1[4]} * ${in2[13]} ) / $FACTOR )) \
$(( ( ${in1[1]} * ${in2[2]} + ${in1[2]} * ${in2[6]} + ${in1[3]} * ${in2[10]} + ${in1[4]} * ${in2[14]} ) / $FACTOR )) \
$(( ( ${in1[1]} * ${in2[3]} + ${in1[2]} * ${in2[7]} + ${in1[3]} * ${in2[11]} + ${in1[4]} * ${in2[15]} ) / $FACTOR )) \
$(( ( ${in1[1]} * ${in2[4]} + ${in1[2]} * ${in2[8]} + ${in1[3]} * ${in2[12]} + ${in1[4]} * ${in2[16]} ) / $FACTOR )) \
$(( ( ${in1[5]} * ${in2[1]} + ${in1[6]} * ${in2[5]} + ${in1[7]} * ${in2[9]} + ${in1[8]} * ${in2[13]} ) / $FACTOR )) \
$(( ( ${in1[5]} * ${in2[2]} + ${in1[6]} * ${in2[6]} + ${in1[7]} * ${in2[10]} + ${in1[8]} * ${in2[14]} ) / $FACTOR )) \
$(( ( ${in1[5]} * ${in2[3]} + ${in1[6]} * ${in2[7]} + ${in1[7]} * ${in2[11]} + ${in1[8]} * ${in2[15]} ) / $FACTOR )) \
$(( ( ${in1[5]} * ${in2[4]} + ${in1[6]} * ${in2[8]} + ${in1[7]} * ${in2[12]} + ${in1[8]} * ${in2[16]} ) / $FACTOR )) \
$(( ( ${in1[9]} * ${in2[1]} + ${in1[10]} * ${in2[5]} + ${in1[11]} * ${in2[9]} + ${in1[12]} * ${in2[13]} ) / $FACTOR )) \
$(( ( ${in1[9]} * ${in2[2]} + ${in1[10]} * ${in2[6]} + ${in1[11]} * ${in2[10]} + ${in1[12]} * ${in2[14]} ) / $FACTOR )) \
$(( ( ${in1[9]} * ${in2[3]} + ${in1[10]} * ${in2[7]} + ${in1[11]} * ${in2[11]} + ${in1[12]} * ${in2[15]} ) / $FACTOR )) \
$(( ( ${in1[9]} * ${in2[4]} + ${in1[10]} * ${in2[8]} + ${in1[11]} * ${in2[12]} + ${in1[12]} * ${in2[16]} ) / $FACTOR )) \
$(( ( ${in1[13]} * ${in2[1]} + ${in1[14]} * ${in2[5]} + ${in1[15]} * ${in2[9]} + ${in1[16]} * ${in2[13]} ) / $FACTOR )) \
$(( ( ${in1[13]} * ${in2[2]} + ${in1[14]} * ${in2[6]} + ${in1[15]} * ${in2[10]} + ${in1[16]} * ${in2[14]} ) / $FACTOR )) \
$(( ( ${in1[13]} * ${in2[3]} + ${in1[14]} * ${in2[7]} + ${in1[15]} * ${in2[11]} + ${in1[16]} * ${in2[15]} ) / $FACTOR )) \
$(( ( ${in1[13]} * ${in2[4]} + ${in1[14]} * ${in2[8]} + ${in1[15]} * ${in2[12]} + ${in1[16]} * ${in2[16]} ) / $FACTOR ))\)
EOF
}

function mMulFast() {
    shift
    cat <<- EOF
$(( ( ${1} * ${18} + ${2} * ${22} + ${3} * ${26} + ${4} * ${30} ) / $FACTOR )) \
$(( ( ${1} * ${19} + ${2} * ${23} + ${3} * ${27} + ${4} * ${31} ) / $FACTOR )) \
$(( ( ${1} * ${20} + ${2} * ${24} + ${3} * ${28} + ${4} * ${32} ) / $FACTOR )) \
$(( ( ${1} * ${21} + ${2} * ${25} + ${3} * ${29} + ${4} * ${33} ) / $FACTOR )) \
$(( ( ${5} * ${18} + ${6} * ${22} + ${7} * ${26} + ${8} * ${30} ) / $FACTOR )) \
$(( ( ${5} * ${19} + ${6} * ${23} + ${7} * ${27} + ${8} * ${31} ) / $FACTOR )) \
$(( ( ${5} * ${20} + ${6} * ${24} + ${7} * ${28} + ${8} * ${32} ) / $FACTOR )) \
$(( ( ${5} * ${21} + ${6} * ${25} + ${7} * ${29} + ${8} * ${33} ) / $FACTOR )) \
$(( ( ${9} * ${18} + ${10} * ${22} + ${11} * ${26} + ${12} * ${30} ) / $FACTOR )) \
$(( ( ${9} * ${19} + ${10} * ${23} + ${11} * ${27} + ${12} * ${31} ) / $FACTOR )) \
$(( ( ${9} * ${20} + ${10} * ${24} + ${11} * ${28} + ${12} * ${32} ) / $FACTOR )) \
$(( ( ${9} * ${21} + ${10} * ${25} + ${11} * ${29} + ${12} * ${33} ) / $FACTOR )) \
$(( ( ${13} * ${18} + ${14} * ${22} + ${15} * ${26} + ${16} * ${30} ) / $FACTOR )) \
$(( ( ${13} * ${19} + ${14} * ${23} + ${15} * ${27} + ${16} * ${31} ) / $FACTOR )) \
$(( ( ${13} * ${20} + ${14} * ${24} + ${15} * ${28} + ${16} * ${32} ) / $FACTOR )) \
$(( ( ${13} * ${21} + ${14} * ${25} + ${15} * ${29} + ${16} * ${33} ) / $FACTOR ))
EOF
}
