#!/bin/bash
# 项目环境一键清理脚本
# 清理网络命名空间、veth网卡、清空iptables规则

echo "===== 开始清理实验环境 ====="

# 删除三个命名空间
ip netns del client 2>/dev/null
ip netns del router 2>/dev/null
ip netns del server 2>/dev/null
ip netns del outer 2>/dev/null

# 清空iptables nat表和filter表规则
iptables -t nat -F
iptables -t nat -X
iptables -F
iptables -X

# 删除定时任务（可选，如果想保留定时任务就注释掉下面这行）
# crontab -r

echo "===== 清理完成 ====="
echo "命名空间、虚拟网卡、iptables规则已清除"
                                
