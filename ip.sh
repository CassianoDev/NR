##Liberar porta do UnlockServer
/sbin/iptables -I INPUT -m state --state NEW -p tcp --dport 40010 -j ACCEPT

### 1: Drop invalid packets ###
/sbin/iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

### 2: Drop TCP packets that are new and are not SYN ###
/sbin/iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

### 3: Drop SYN packets with suspicious MSS value ###
/sbin/iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

### 4: Block packets with bogus TCP flags ###
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
/sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP

### 6: Drop ICMP (you usually don't need this protocol) ###
/sbin/iptables -t mangle -A PREROUTING -p icmp -j DROP

### 7: Drop fragments in all chains ###
/sbin/iptables -t mangle -A PREROUTING -f -j DROP
### 8: Limit connections per source IP ###
/sbin/iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 5900 -j REJECT --reject-with tcp-reset
/sbin/iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 5900 -j REJECT --reject-with tcp-reset
#/sbin/iptables -A INPUT -p tcp --syn --dport 40010 -m connlimit --connlimit-above 500 -j REJECT --reject-with tcp-reset

iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 443 -j ACCEPT
iptables -A OUTPUT -p udp --sport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8000 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8080 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8080 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 7300 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 7300 -j ACCEPT
iptables -A OUTPUT -p udp --sport 7300 -j ACCEPT
iptables -A OUTPUT -p udp --dport 7300 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8880 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2052 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2082 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2086 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2095 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8880 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2052 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2082 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2086 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2095 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2053 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2083 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2087 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2096 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2053 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2083 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2087 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 2096 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 27017 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 27017 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6379 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 6379 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5228 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5229 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5230 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 5228 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 5229 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 5230 -j ACCEPT

#META/FACEBOOK/INSTA/WHATSAPP CIDR
iptables -A OUTPUT -p udp -s 31.13.64.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.65.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.66.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.67.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.69.240/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.70.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.71.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.72.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.73.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.74.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.75.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.76.81/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.77.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.79.195/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.80.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.81.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.82.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.83.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.84.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.85.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.86.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.87.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.88.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.88.57/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.90.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.91.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.92.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.93.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.95.63/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.75.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.93.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.198.204/30 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.210.32/30 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.210.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.225.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.235.248/30 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.22.240.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.23.90.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 50.97.57.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 75.126.39.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.174.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.176.192/26 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.177.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.180.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.254.65/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.255.224/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 108.168.255.227/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.0.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.5.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.46.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.48.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.58.0/25 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.61.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.224.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.233.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.249.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.249.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 158.85.254.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.45.71.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.45.71.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.53.29.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.53.71.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.53.250.128/26 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.54.2.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.54.51.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.54.55.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.54.210.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.54.222.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.55.69.128/26 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.55.74.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 169.55.235.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.192.162.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.192.219.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.192.222.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.192.231.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.193.205.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.193.230.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.193.230.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.193.230.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.193.239.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.36.208.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.36.210.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.36.251.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.199.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.215.28/30 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.217.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.231.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.243.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 174.37.251.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 179.60.192.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 179.60.193.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 179.60.195.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.73.176/28 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.136.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.147.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.161.64/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.161.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.173.116/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.179.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.195.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.201.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.204.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 184.173.250.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 192.155.212.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.11.193.182/31 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.11.212.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.11.217.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.11.251.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.23.80.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.23.86.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 198.23.87.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 208.43.115.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 208.43.117.79/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 208.43.117.136/32 -j ACCEPT
iptables -A OUTPUT -p udp -s 208.43.122.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -s 204.15.20.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.24.0/21 -j ACCEPT
iptables -A OUTPUT -p udp -s 173.252.64.0/18 -j ACCEPT
iptables -A OUTPUT -p udp -s 103.4.96.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 74.119.76.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 69.171.224.0/19 -j ACCEPT
iptables -A OUTPUT -p udp -s 69.63.176.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -s 31.13.64.0/18 -j ACCEPT
iptables -A OUTPUT -p udp -s 66.220.144.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -s 199.59.148.0/22 -j ACCEPT
#META/FACEBOOK/INSTA/WHATSAPP CIDR

#TELEGRAM CIDR
iptables -A OUTPUT -p udp -s 91.108.56.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.108.4.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.108.8.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.108.16.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.108.12.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 149.154.160.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.105.192.0/23 -j ACCEPT
iptables -A OUTPUT -p udp -s 91.108.20.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -s 185.76.151.0/24 -j ACCEPT
#TELEGRAM CIDR

#META/FACEBOOK/INSTA/WHATSAPP CIDR
iptables -A OUTPUT -p tcp -s 31.13.64.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.65.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.66.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.67.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.69.240/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.70.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.71.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.72.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.73.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.74.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.75.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.76.81/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.77.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.79.195/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.80.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.81.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.82.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.83.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.84.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.85.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.86.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.87.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.88.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.88.57/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.90.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.91.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.92.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.93.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.95.63/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.75.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.93.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.198.204/30 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.210.32/30 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.210.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.225.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.235.248/30 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.22.240.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.23.90.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 50.97.57.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 75.126.39.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.174.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.176.192/26 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.177.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.180.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.254.65/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.255.224/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 108.168.255.227/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.0.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.5.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.46.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.48.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.58.0/25 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.61.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.224.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.233.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.249.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.249.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 158.85.254.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.45.71.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.45.71.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.53.29.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.53.71.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.53.250.128/26 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.54.2.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.54.51.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.54.55.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.54.210.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.54.222.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.55.69.128/26 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.55.74.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 169.55.235.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.192.162.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.192.219.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.192.222.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.192.231.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.193.205.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.193.230.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.193.230.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.193.230.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.193.239.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.36.208.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.36.210.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.36.251.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.199.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.215.28/30 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.217.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.231.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.243.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 174.37.251.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 179.60.192.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 179.60.193.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 179.60.195.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.73.176/28 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.136.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.147.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.161.64/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.161.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.173.116/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.179.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.195.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.201.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.204.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 184.173.250.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 192.155.212.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.11.193.182/31 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.11.212.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.11.217.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.11.251.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.23.80.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.23.86.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 198.23.87.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 208.43.115.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 208.43.117.79/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 208.43.117.136/32 -j ACCEPT
iptables -A OUTPUT -p tcp -s 208.43.122.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -s 204.15.20.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.24.0/21 -j ACCEPT
iptables -A OUTPUT -p tcp -s 173.252.64.0/18 -j ACCEPT
iptables -A OUTPUT -p tcp -s 103.4.96.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 74.119.76.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 69.171.224.0/19 -j ACCEPT
iptables -A OUTPUT -p tcp -s 69.63.176.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -s 31.13.64.0/18 -j ACCEPT
iptables -A OUTPUT -p tcp -s 66.220.144.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -s 199.59.148.0/22 -j ACCEPT
#META/FACEBOOK/INSTA/WHATSAPP CIDR

#TELEGRAM CIDR
iptables -A OUTPUT -p tcp -s 91.108.56.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.108.4.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.108.8.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.108.16.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.108.12.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 149.154.160.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.105.192.0/23 -j ACCEPT
iptables -A OUTPUT -p tcp -s 91.108.20.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -s 185.76.151.0/24 -j ACCEPT
#TELEGRAM CIDR

#META/FACEBOOK/INSTA/WHATSAPP CIDR
iptables -A OUTPUT -p udp -d 31.13.64.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.65.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.66.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.67.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.69.240/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.70.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.71.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.72.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.73.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.74.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.75.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.76.81/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.77.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.79.195/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.80.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.81.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.82.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.83.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.84.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.85.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.86.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.87.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.88.49/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.88.57/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.90.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.91.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.92.52/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.93.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.95.63/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.75.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.93.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.198.204/30 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.210.32/30 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.210.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.225.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.235.248/30 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.22.240.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.23.90.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 50.97.57.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 75.126.39.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.174.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.176.192/26 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.177.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.180.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.254.65/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.255.224/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 108.168.255.227/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.0.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.5.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.46.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.48.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.58.0/25 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.61.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.224.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.233.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.249.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.249.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 158.85.254.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.45.71.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.45.71.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.53.29.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.53.71.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.53.250.128/26 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.54.2.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.54.51.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.54.55.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.54.210.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.54.222.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.55.69.128/26 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.55.74.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 169.55.235.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.192.162.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.192.219.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.192.222.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.192.231.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.193.205.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.193.230.96/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.193.230.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.193.230.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.193.239.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.36.208.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.36.210.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.36.251.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.199.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.215.28/30 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.217.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.231.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.243.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 174.37.251.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 179.60.192.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 179.60.193.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 179.60.195.51/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.73.176/28 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.136.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.147.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.161.64/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.161.160/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.173.116/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.179.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.195.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.201.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.204.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 184.173.250.53/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 192.155.212.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.11.193.182/31 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.11.212.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.11.217.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.11.251.32/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.23.80.0/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.23.86.224/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 198.23.87.64/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 208.43.115.192/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 208.43.117.79/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 208.43.117.136/32 -j ACCEPT
iptables -A OUTPUT -p udp -d 208.43.122.128/27 -j ACCEPT
iptables -A OUTPUT -p udp -d 204.15.20.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.24.0/21 -j ACCEPT
iptables -A OUTPUT -p udp -d 173.252.64.0/18 -j ACCEPT
iptables -A OUTPUT -p udp -d 103.4.96.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 74.119.76.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 69.171.224.0/19 -j ACCEPT
iptables -A OUTPUT -p udp -d 69.63.176.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -d 31.13.64.0/18 -j ACCEPT
iptables -A OUTPUT -p udp -d 66.220.144.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -d 199.59.148.0/22 -j ACCEPT
#META/FACEBOOK/INSTA/WHATSAPP CIDR

#TELEGRAM CIDR
iptables -A OUTPUT -p udp -d 91.108.56.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.108.4.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.108.8.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.108.16.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.108.12.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 149.154.160.0/20 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.105.192.0/23 -j ACCEPT
iptables -A OUTPUT -p udp -d 91.108.20.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 185.76.151.0/24 -j ACCEPT
#TELEGRAM CIDR

#PUBGCIDR
iptables -A OUTPUT -p udp -d 43.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p udp -d 49.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p udp -d 101.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p udp -d 119.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p udp -d 129.226.0.0/16 -j ACCEPT
iptables -A OUTPUT -p udp -d 150.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p udp -d 159.138.0.0/16 -j ACCEPT
iptables -A OUTPUT -p udp -d 162.62.0.0/16 -j ACCEPT
iptables -A OUTPUT -p udp -d 170.0.0.0/22 -j ACCEPT
iptables -A OUTPUT -p udp -d 203.0.0.0/8 -j ACCEPT
#PUBGCIDR

#META/FACEBOOK/INSTA/WHATSAPP CIDR
iptables -A OUTPUT -p tcp -d 31.13.64.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.65.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.66.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.67.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.69.240/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.70.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.71.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.72.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.73.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.74.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.75.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.76.81/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.77.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.79.195/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.80.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.81.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.82.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.83.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.84.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.85.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.86.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.87.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.88.49/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.88.57/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.90.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.91.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.92.52/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.93.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.95.63/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.75.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.93.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.198.204/30 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.210.32/30 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.210.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.225.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.235.248/30 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.22.240.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.23.90.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 50.97.57.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 75.126.39.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.174.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.176.192/26 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.177.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.180.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.254.65/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.255.224/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 108.168.255.227/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.0.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.5.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.46.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.48.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.58.0/25 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.61.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.224.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.233.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.249.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.249.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 158.85.254.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.45.71.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.45.71.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.53.29.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.53.71.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.53.250.128/26 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.54.2.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.54.51.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.54.55.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.54.210.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.54.222.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.55.69.128/26 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.55.74.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 169.55.235.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.192.162.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.192.219.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.192.222.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.192.231.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.193.205.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.193.230.96/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.193.230.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.193.230.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.193.239.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.36.208.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.36.210.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.36.251.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.199.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.215.28/30 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.217.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.231.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.243.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 174.37.251.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 179.60.192.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 179.60.193.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 179.60.195.51/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.73.176/28 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.136.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.147.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.161.64/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.161.160/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.173.116/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.179.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.195.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.201.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.204.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 184.173.250.53/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.155.212.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.11.193.182/31 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.11.212.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.11.217.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.11.251.32/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.23.80.0/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.23.86.224/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 198.23.87.64/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 208.43.115.192/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 208.43.117.79/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 208.43.117.136/32 -j ACCEPT
iptables -A OUTPUT -p tcp -d 208.43.122.128/27 -j ACCEPT
iptables -A OUTPUT -p tcp -d 204.15.20.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.24.0/21 -j ACCEPT
iptables -A OUTPUT -p tcp -d 173.252.64.0/18 -j ACCEPT
iptables -A OUTPUT -p tcp -d 103.4.96.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 74.119.76.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 69.171.224.0/19 -j ACCEPT
iptables -A OUTPUT -p tcp -d 69.63.176.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -d 31.13.64.0/18 -j ACCEPT
iptables -A OUTPUT -p tcp -d 66.220.144.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -d 199.59.148.0/22 -j ACCEPT
#META/FACEBOOK/INSTA/WHATSAPP CIDR

#TELEGRAM CIDR
iptables -A OUTPUT -p tcp -d 91.108.56.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.108.4.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.108.8.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.108.16.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.108.12.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 149.154.160.0/20 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.105.192.0/23 -j ACCEPT
iptables -A OUTPUT -p tcp -d 91.108.20.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 185.76.151.0/24 -j ACCEPT
#TELEGRAM CIDR

#PUBGCIDR
iptables -A OUTPUT -p tcp -d 43.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp -d 49.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp -d 101.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp -d 119.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp -d 129.226.0.0/16 -j ACCEPT
iptables -A OUTPUT -p tcp -d 150.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp -d 159.138.0.0/16 -j ACCEPT
iptables -A OUTPUT -p tcp -d 162.62.0.0/16 -j ACCEPT
iptables -A OUTPUT -p tcp -d 170.0.0.0/22 -j ACCEPT
iptables -A OUTPUT -p tcp -d 203.0.0.0/8 -j ACCEPT
#PUBGCIDR
iptables -A OUTPUT -p tcp -j DROP
ip6tables -A OUTPUT -p tcp -j DROP
iptables -A OUTPUT -p udp -j DROP
ip6tables -A OUTPUT -p udp -j DROP
ulimit -n 1048576
