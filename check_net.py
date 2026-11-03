#!/usr/bin/env python3
import subprocess

def ping_test():
    """测试client能否ping通server"""
    cmd = ["ip", "netns", "exec", "client", "ping", "-c", "2", "-W", "2", "192.$
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return res.returncode == 0

def http_test():
    """测试DNAT 8080端口映射服务"""
    cmd = ["ip", "netns", "exec", "client", "curl", "-s", "--connect-timeout", $
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return res.returncode == 0

if __name__ == "__main__":
    print("===== Linux网关网络巡检开始 =====")
    ping_ok = ping_test()
    http_ok = http_test()

    if ping_ok:
        print("[正常] ICMP连通性检测成功")
    else:
        print("[告警] ICMP连通性检测失败！")

    if http_ok:
        print("[正常] DNAT端口映射服务访问成功")
    else:
        print("[告警] DNAT端口映射服务访问失败！")
   print("===== 本轮巡检结束 =====\n")
