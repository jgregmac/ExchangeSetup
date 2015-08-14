netsh int ipv4 set dynamicport tcp start=49152 num=16383
netsh int ipv4 set dynamicport udp start=49152 num=16383
netsh int ipv6 set dynamicport tcp start=49152 num=16383
netsh int ipv4 set dynamicport udp start=49152 num=16383
netsh int ipv4 show dynamicport tcp
netsh int ipv4 show dynamicport udp
netsh int ipv6 show dynamicport tcp
netsh int ipv6 show dynamicport udp