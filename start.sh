#!/bin/bash
# 一键搭建项目环境：创建命名空间、veth网卡、配置IP、开启转发、配置iptables

echo "===== 开始搭建网络实验环境 ====="

# 1. 创建三个网络命名空间
ip netns add client
ip netns add router
ip netns add server

# 2. 创建veth pair虚拟网卡对（client<->router）
ip link add veth-c type veth peer name veth-r1
# 把veth-c放进client命名空间，veth-r1留在router
ip link set veth-c netns client
ip link set veth-r1 netns router

# 3. 创建veth pair虚拟网卡对（router<->server）
ip link add veth-s type veth peer name veth-r2
# 把veth-s放进server命名空间，veth-r2放进router命名空间
ip link set veth-s netns server
ip link set veth-r2 netns router

# 4. 配置client侧IP和网卡
ip netns exec client ip addr add 192.168.10.10/24 dev veth-c
ip netns exec client ip link set veth-c up
ip netns exec client ip link set lo up
# client默认网关指向router
ip netns exec client ip route add default via 192.168.10.1

# 5. 配置router侧两个网卡IP
ip netns exec router ip addr add 192.168.10.1/24 dev veth-r1
ip netns exec router ip link set veth-r1 up
ip netns exec router ip addr add 192.168.20.1/24 dev veth-r2
ip netns exec router ip link set veth-r2 up
ip netns exec router ip link set lo up

# 6. 配置server侧IP和网卡
ip netns exec server ip addr add 192.168.20.10/24 dev veth-s
ip netns exec server ip link set veth-s up
ip netns exec server ip link set lo up
# server默认网关指向router
ip netns exec server ip route add default via 192.168.20.1

# 7. 开启router的IP转发（核心！让router能转发数据包）
ip netns exec router sysctl -w net.ipv4.ip_forward=1

# 8. 配置SNAT规则：内网client访问外网，源IP改成router的192.168.20.1
ip netns exec router iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o veth-$

# 9. 配置DNAT规则：访问router的8080端口，转发到server的80端口
ip netns exec router iptables -t nat -A PREROUTING -d 192.168.20.1 -p tcp --dpo$

echo "===== 环境搭建完成 ====="
echo "测试命令："
echo "  ip netns exec client ping 192.168.20.10"
echo "  ip netns exec server python3 -m http.server 80"
echo "  ip netns exec client curl 192.168.20.1:8080"
