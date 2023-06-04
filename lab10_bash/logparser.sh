#!/bin/bash
logFile="./access-4560-644067.log.txt"
lastDateFile='./lastDate.txt'
outputFile=./Report_$(date +%Y-%m-%d_%H:%M).txt
email='stanwork43@gmail.com'
# Читаем значения из файла и присваиваем переменной, нужно для определения пополнялся ли файл лога и с какого места делать считывание файла
number=$(cat ./lines 2>/dev/null);status=$?

# Считаем строки и записываем в переменную значение первого поля, которое считает количество строк.
checkLines=$(wc $logFile | awk '{print $1}')

# Если возвращается пустое значение, т.е. его нет, тогда считаем количество строк и записываем значение в файл
if ! [ -n "$number" ]
then
    # Дата начала и конца
    # Записываем в переменную значение полей 4 и 5, удалив квадратные скобки, отправив на последний pipe только первую строку.
    StartTime=$(awk '{print $4 $5}' $logFile  | sed 's/\[//; s/\]//' | sed -n 1p)
    # Записываем в переменную значение полей 4 и 5, удалив квадратные скобки, отправив на последний pipe только последнюю строку, взятую из переменной checkLines.
    EndTime=$(awk '{print $4 $5}' $logFile | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    # Записываем  количество строк в файле
    echo $checkLines > ./lines
    # Определение количества IP запросов с IP адресов
    #NR - Встроенная переменная AWK определяющая количество записей
    IP=$(awk "NR>$checkLines" $logFile  | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Список запрашиваемых URL (с наибольшим кол-вом запросов)
    addresses=$(awk '($9 ~ /200/)' $logFile |awk '{print $11}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки c момента последнего запуска
    errors=$(cat $logFile | cut -d '"' -f3 | cut -d ' ' -f2 | grep -vE '[23]0[0-9]' |sort | uniq -c | sort -rn)
    # Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
    codes=$(cat $logFile | cut -d '"' -f3 | cut -d ' ' -f2 |sort | uniq -c | sort -rn)
    # Запись отчета в файл
    echo -e "Данные за период:$StartTime-$EndTime\n$IP\n\n"Список запрашиваемых URL:"\n$addresses\n\n"Ошибки c момента последнего запуска:"\n$errors\n\n"Список всех кодов HTTP ответа с указанием их кол-ва:"\n$codes" > $outputFile
    # Отправка отчета на почту
    sendmail  $email < $outputFile
else
    # Дата начала и конца
    StartTime=$(awk '{print $4 $5}' $logFile | sed 's/\[//; s/\]//' | sed -n "$(($number+1))"p)
    EndTime=$(awk '{print $4 $5}' $logFile | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    # Определение количества IP запросов с IP адресов
    IP=$(awk "NR>$(($number+1))" $logFile | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Список запрашиваемых URL (с наибольшим кол-вом запросов)
    addresses=$(awk '($9 ~ /200/)' $logFile |awk '{print $11}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки c момента последнего запуска
    errors=$(cat $logFile | cut -d '"' -f3 | cut -d ' ' -f2 | grep -vE '[23]0[0-9]' | sort | uniq -c | sort -rn)
    # Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта
    codes=$(cat $logFile | cut -d '"' -f3 | cut -d ' ' -f2 |sort | uniq -c | sort -rn)
    # Записываем количество строк в файле
    echo $checkLines > ./lines
    # Запись отчета в файл
    echo -e "Данные за период:$StartTime-$EndTime\n$IP\n\n"Список запрашиваемых URL:"\n$addresses\n\n"Ошибки c момента последнего запуска:"\n$errors\n\n"Список всех кодов HTTP ответа с указанием их кол-ва:"\n$codes" > $outputFile
    # Отправка отчета на почту
    sendmail  $email < $outputFile
fi