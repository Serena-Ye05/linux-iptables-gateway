# Linux iptables 网关实验（SNAT + DNAT）
> 网络工程专业 | Linux软路由NAT仿真项目，使用Linux网络命名空间 + veth pair 搭建，无需多台虚拟机。

## ✨ 项目简介
本项目在单台Ubuntu虚拟机内，利用Linux网络命名空间模拟多台主机，搭建软路由网关，实现：
- SNAT 源地址转换：内网主机访问外网
- DNAT 目的地址转换：外网访问内网服务端口映射
- iptables ACL 访问控制策略
- tcpdump 抓包验证NAT报文变化

## 🛠️ 技术栈
Linux、iptables、网络命名空间(ip netns)、veth pair、tcpdump、Git、GitHub

## 📐 拓扑说明
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

## 📌 验证结果
- SNAT：客户端访问外网，报文源IP被替换为网关出口IP
- DNAT：外网访问网关端口，流量转发到内网服务主机
- ACL：可以限制ping，放行HTTP服务

## 💡 项目亮点
使用单虚拟机完成多节点网络仿真，结合数通NAT原理与Linux运维能力，适合网络工程学习与简历展示。

