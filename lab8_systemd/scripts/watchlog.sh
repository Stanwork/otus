#!/bin/bash
WORD=$1
LOG=$2
DATE=`/bin/date`
if grep $WORD $LOG &> /dev/null; then
    logger "$DATE: I found word, Master!"
	exit 0
else
    exit 0
fi
