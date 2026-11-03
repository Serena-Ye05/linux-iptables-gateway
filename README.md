# Linux iptables 网关实验（SNAT + DNAT）

## ✨ 项目简介
本项目在单台Ubuntu虚拟机内，利用Linux网络命名空间模拟多台主机，搭建软路由网关，实现：
- SNAT 源地址转换：内网主机访问外网
- DNAT 目的地址转换：外网访问内网服务端口映射
- iptables ACL 访问控制策略
- tcpdump 抓包验证NAT报文变化

## 🛠️ 技术栈
- Linux 网络命名空间（netns）
- veth 虚拟网卡对
- iptables NAT 表
- shell 自动化脚本
- tcpdump

## 🔌 拓扑说明
- client：内网客户端
- router：Linux软路由网关（开启ip转发，配置NAT）
- server：内网Web服务端
- extern：模拟外网主机

## 📝 实验步骤
1. 创建网络命名空间，使用veth pair虚拟网线互连
2. 配置各网卡IP，配置路由
3. 开启Linux内核IP转发
4. 配置SNAT：内网主机访问外网
5. 配置DNAT：外网访问内网80端口服务
6. 配置iptables ACL策略，控制访问权限
7. tcpdump 在网关两侧抓包，验证IP地址转换效果

## ✅ 验证结果
- SNAT：客户端访问外网，报文源IP被替换为网关出口IP
- DNAT：外网访问网关端口，流量转发到内网服务主机
- ACL：可以限制ping，放行HTTP服务

## 📖 使用方法
```bash
# 1. 克隆项目
git clone https://github.com/Serena-Ye05/linux-iptables-gateway.git
cd linux-iptables-gateway

# 2. 添加脚本执行权限
chmod +x start.sh clean.sh

# 3. 一键搭建实验环境
sudo ./start.sh

# 4. 功能验证
# 测试客户端和服务端连通性
ip netns exec client ping 192.168.20.10

# 新开终端，在服务端启动HTTP服务
ip netns exec server python3 -m http.server 80

# 测试DNAT端口转发
ip netns exec client curl 192.168.20.1:8080

# 5. 实验结束，清理环境
sudo ./clean.sh
```

## 📡 使用 tcpdump 观测流量地址转换

可以在 router 网络命名空间中使用 tcpdump，直观查看 SNAT、DNAT 的地址转换过程。

操作步骤：

```
# 第一步：在 router 的 veth-r1 网卡开启抓包（先执行，保持监听）
ip netns exec router tcpdump -i veth-r1 -nn

# 第二步：新开终端，在 server 节点启动 HTTP 服务
ip netns exec server python3 -m http.server 80

# 第三步：再开终端，从 client 发起访问请求
ip netns exec client curl 192.168.20.1:8080
```

原理说明：

- 第一次 curl 请求会新建 TCP 连接，完成三次握手，会产生完整报文。**注意：执行 curl 之后报文不一定马上打印出来，可能需要等待一小段时间才会输出。**
- 如果紧接着重复执行 curl，内核连接跟踪模块（conntrack）会复用已经建立好的 TCP 连接，不会再次发起完整握手，报文很少甚至肉眼看不到输出。
- iptables NAT 依赖内核连接跟踪表，已有连接条目会直接转发流量，不再重复执行完整的地址转换流程，因此会出现有时能抓到报文、有时看不到报文的情况，属于正常现象。
- TCP 四次挥手是连接断开阶段的报文，在 curl 请求结束之后才会出现。
