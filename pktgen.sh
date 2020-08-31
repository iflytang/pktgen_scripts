#!/bin/bash

## when SIGINT || SIGQUIT || SIGKILL, we should stop pktgen and then quit, with 'trap' command
trap 'signal_handler; exit' SIGINT SIGQUIT SIGKILL
function signal_handler() {
    ## stop to send packet
    echo -e "\ntsf: the shell script will be stopped, and pktgen stops running ..."
    echo "pktgen.clr" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}  # clear statistics
    echo "pktgen.stop(${PORT_ID})" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
}

# # traffic-001, [160000, 170000] as test set. OFC 2021 packet layer, pkt_size: 512
export trace=Traffic-test-001           # in Gbps, every 1s to change rate.
                                        # we repeat first second for twice, and collector choose the latter one
export run_time=Traffic-test-001-time   # in second

# # fixed packet rate, OFC 2021 packet layer, pkt_size: 1024, 8 Gbps
export trace=OFC2021_optical_layer_exp_trace     # in Gbps, every 1s to change rate.
export run_time=OFC2021_optical_layer_exp_time   # in second

# # flow_A, used for bandwidth monitor, figure 16 (a)
#export trace=flow_A         # in Gbps, every 1s to change rate, last for 44s, loops: 10, sampling rate: 7.1%
#export run_time=time_A         # in second

# # flow_B, used for bandwidth monitor, figure 16 (b)
#export trace=flow_B         # in Gbps, every 1s to change rate, last for 55s, loops: 10, sampling rate: 8.2%
#export run_time=time_B         # in second

# # flow_C, used for benchmark, figure 15 (a), scenario 1: 64B, [0.336, 0.672] Gbps, adjust sampling rate
#export trace=flow_C         # in Gbps, every 8s to change rate, last for 30*8=240s, loops: 10
#export run_time=time_C         # in second

# # flow_D, used for benchmark, figure 15 (b), scenario 2: 64B, 0.672 Gbps, adjust port by ECMP; OR for figure 18 (a)
#export trace=flow_D         # in Gbps, every 8s to change rate, last for 30*8=240s, loops: 10
#export run_time=time_D         # in second

## pktgen tcp ip and port
export PKTGEN_IP="127.0.0.1"
export PKTGEN_PORT=22022

# # pktgen running port and rate
export PORT_RATE=10              # in Gbps
export PORT_ID_0='0'
export PORT_ID_1='1'
export PERCENTRAGE_FACTOR=10     # convert Gbps to %

## pktgen configuration, change here
export PORT_ID=${PORT_ID_0}
export PKT_SIZE=1024            # flow_A,flow_B:1024B; flow_C,flow_D:64B
export SRC_IP='10.0.0.1/32'    # must have prefix
export DST_IP='10.0.0.2'       # cannot have prefix

trace_index=0
time_index=0
#java --version

## read trace, unit: Gbps
while read trace_line
do
    trace_array[$trace_index]=${trace_line}*${PERCENTRAGE_FACTOR}    # in percentage, 10 Gbps * percentage = real_bandwidth
   # echo ${trace_array[$trace_index]}
    let trace_index++
done < ${trace}

## read time, unit: second
while read time_line
do
    time_array[time_index]=${time_line}
    let time_index++
done < ${run_time}

# set src_ip and dst_ip
echo "pktgen.set_ipaddr(${PORT_ID}, 'src', '${SRC_IP}')" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
echo "pktgen.set_ipaddr(${PORT_ID}, 'dst', '${DST_IP}')" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}

# set packet protocol
echo "pktgen.set_proto(${PORT_ID}, 'tcp')" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}

# set packet size
echo "pktgen.set(${PORT_ID}, 'size', ${PKT_SIZE})" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
#echo ${PORT_ID}

## start to send packet
echo "pktgen.start(${PORT_ID})" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
#sleep 1s

## auto to adjust packet-rate
STOP_POINTS=2000
for ((i=0;i<$trace_index;i++))
do
    echo "pktgen.set(${PORT_ID},'rate',${trace_array[i]})" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
    sleep ${time_array[i]}s
    #sleep 1s

    if (($i>$STOP_POINTS))
    then
        let STOP_POINTS++
        echo "tsf: stop to send traffic after ${STOP_POINTS} points."
        break
    fi
done

## stop to send packet
echo "pktgen.stop(${PORT_ID})" | socat - TCP4:${PKTGEN_IP}:${PKTGEN_PORT}
