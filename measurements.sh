#!/bin/sh


for i in `seq 2 6`
do
    sar -P ALL 1 60 >measurements_bb/proc_norm_${i}.txt &
    mix run --no-halt run.exs norm $i | tee measurements_bb/times_norm_${i}.txt && pkill -SIGINT sar
done

for i in `seq 2 6`
do
    sar -P ALL 1 60 >measurements_bb/proc_dist_${i}.txt &
    mix run --no-halt run.exs dist $i | tee measurements_bb/times_dist_${i}.txt && pkill -SIGINT sar
done
