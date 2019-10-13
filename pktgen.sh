#!/bin/bash

# # change flow file here
PORT_RATE = 10              # in Gbps

# # flow_A, used for bandwidth monitor, figure 16 (a)
trace_file = flow_A         # in Gbps, every 1s to change rate, last for 44s, loops: 10, sampling rate: 7.1%
trace_time = time_A         # in second

# # flow_B, used for bandwidth monitor, figure 16 (b)
#trace_file = flow_B         # in Gbps, every 1s to change rate, last for 55s, loops: 10, sampling rate: 8.2%
#trace_time = time_B         # in second

# # flow_C, used for benchmark, figure 15 (a), scenario 1: 64B, 0.672 Mpps, adjust sampling rate
#trace_file = flow_C         # in Gbps, every 8s to change rate, last for 30*8=240s, loops: 10
#trace_time = time_C         # in second

# # flow_D, used for benchmark, figure 15 (b), scenario 2: 64B, [0.336, 0.672] Mpps, adjust port by ECMP
#trace_file = flow_D         # in Gbps, every 8s to change rate, last for 30*8=240s, loops: 10
#trace_time = time_D         # in second

trace = ${trace_file} / ${PORT_RATE} * 100   # in percentage (%)
time_time = ${trace_time}                    # in second

trace_index=0
time_index=0

#java --version
while read line
do
    trace_array[$trace_index]=$line
   # echo ${trace_array[$trace_index]}
    let trace_index++
done < ${trace}
#echo ${trace_array[0]}
#echo ${trace_array[1]}
#echo ${trace_array[2]}

while read b
do
    time_array[time_index]=$b
    let time_index+=1
done < ${time_time}


#echo "pktgen.start ('0')" | socat - TCP4:127.0.0.1:22022
echo "pktgen.set('0','rate',${trace_array[0]})" | socat - TCP4:127.0.0.1:22022
#sleep 1s
echo "pktgen.start('0')" | socat - TCP4:127.0.0.1:22022
#sleep 1s

for ((i=0;i<$trace_index;i++))
do
    echo "pktgen.set('0','rate',${trace_array[i]})" | socat - TCP4:127.0.0.1:22022
    sleep ${time_array[i]}
done
