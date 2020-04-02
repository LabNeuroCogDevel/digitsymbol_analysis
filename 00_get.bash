#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
cd $(dirname $0)

#
# 20200402WF - init
#    
# eptxt from lncdtools

[ ! -d txt ] && mkdir txt

eptxt \
   -p '\d{8}-\d{5}' \
   ../DigitSymbol-20*-1*.txt \
   >  txt/all_long_raw.txt

Rscript -e "library(LNCDR);library(lubridate); 
read.table('txt/all_long_raw.txt', header=T) %>%
   select(id,task,Running,TrialType,
          digit,symbol,answer,speed.ACC,speed.RT,
          mem,memsym,manswer,mtrace.ACC,mtrace.RT,mtrace.RESP) %>%
   tidyr::separate(id, c('vdate','id')) %>% 
   filter(!is.na(symbol)|!is.na(memsym)) %>% 
   merge(db_query(\"select id,sex,dob from person natural join enroll where etype like 'LunaID'\"), all.x=T, by='id') %>%
   mutate(age = as.numeric(ymd(vdate) - ymd(dob))/365.25) %>%
   write.table(file='txt/all_long.txt',row.names=F)"
