This is a pktgen script to auto adjust the pktgen rate.

- Configure the DPDK, and bind NIC with ```igb_uio``` driver.
```
sudo ./dpdk-devbind.py --bind=igb_uio 0000:af:00.0
```

- Run pktgen. The CLI command as (`-G` enables socket):

```
sdn@IPL231:~/pktgen-dpdk_master/app/x86_64-native-linuxapp-gcc$ sudo ./pktgen -c fff -n 4 -- -p 0x3 -m "[1:2].0" -P -T -G
```

- Run scripts. Adjust the parameters in the pktgen before running.
```
./pktgen.sh
```
