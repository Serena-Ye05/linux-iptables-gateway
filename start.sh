#!/bin/bash

echo "===== 开始搭建网络实验环境 ====="

# 1. 创建三个网络命名空间
ip netns add client
ip netns add router
ip netns add server

# 2. client <--> router 一对veth
ip link add veth-c type veth peer name veth-r1
ip link set veth-c netns client
ip link set veth-r1 netns router

# 3. server <--> router 一对veth
ip link add veth-s type veth peer name veth-r2
ip link set veth-s netns server
ip link set veth-r2 netns router

# 4. 配置 client
ip netns exec client ip addr add 192.168.10.10/24 dev veth-c
ip netns exec client ip link set veth-c up
ip netns exec client ip link set lo up
ip netns exec client ip route add default via 192.168.10.1

# 5. 配置 router
ip netns exec router ip addr add 192.168.10.1/24 dev veth-r1
ip netns exec router ip addr add 192.168.20.1/24 dev veth-r2
ip netns exec router ip link set veth-r1 up
ip netns exec router ip link set veth-r2 up
ip netns exec router ip link set lo up

# 6. 配置 server
ip netns exec server ip addr add 192.168.20.10/24 dev veth-s
ip netns exec server ip link set veth-s up
ip netns exec server ip link set lo up
ip netns exec server ip route add default via 192.168.20.1

# 7. 开启路由转发
ip netns exec router sysctl -w net.ipv4.ip_forward=1

# 8. SNAT
ip netns exec router iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o veth-r2 -j MASQUERADE

# 9. DNAT
ip netns exec router iptables -t nat -A PREROUTING -d 192.168.20.1 -p tcp --dport 8080 \
-j DNAT --to-destination 192.168.20.10:80


echo "===== 环境搭建完成 ====="
echo "  ip netns exec client ping 192.168.20.10"
echo "  ip netns exec server python3 -m http.server 80"
echo "  ip netns exec client curl 192.168.20.1:8080"

