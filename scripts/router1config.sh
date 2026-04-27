#!/bin/bash
# router1-setup.sh - для ВТОРОГО роутера (BACKUP)
# Выполнять ПОСЛЕ установки Ubuntu в VM

echo "=== Настройка Первого роутера (BACKUP) ==="

# 1. Обновляем систему
sudo timedatectl set-timezone Asia/Omsk
sudo apt update
sudo apt upgrade -y


# 2. Устанавливаем необходимые пакеты + KEEPALIVED
sudo apt install -y \
    net-tools \
    iptables-persistent \
    dnsmasq \
    keepalived \
    tcpdump \
    curl \
    wget \
    vim \
    git \
    qemu-guest-agent

# 3. Настраиваем Netplan (статический IP) ДЛЯ ПЕРВОГО РОУТЕРА
sudo tee /etc/netplan/00-router.yaml << 'EOF'
network:
  version: 2
  ethernets:
    # WAN интерфейс
    ens18:
      addresses: [192.168.1.171/24]      # Первый IP в WAN сети!
      dhcp4: false
      dhcp6: false
      accept-ra: false
      link-local: []
      routes:
        - to: 0.0.0.0/0
          via: 192.168.1.250             # Ваш физический шлюз
          metric: 100
          on-link: true
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
    
    # LAN интерфейс  
    ens19:
      addresses: [192.168.5.171/24]      # ПЕРВЫЙ IP в LAN сети!
      dhcp4: false
      dhcp6: false
      accept-ra: false
      link-local: []
EOF

# 4. Применяем Netplan
sudo netplan apply
sleep 3

# 5. Включаем IP forward
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 6. Настраиваем iptables (NAT) - ТОЧНО такие же правила как на первом!
sudo iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
sudo iptables -A FORWARD -i ens19 -o ens18 -j ACCEPT
sudo iptables -A FORWARD -i ens18 -o ens19 -m state --state ESTABLISHED,RELATED -j ACCEPT

# 7. Сохраняем iptables правила
sudo iptables-save | sudo tee /etc/iptables/rules.v4
sudo systemctl enable netfilter-persistent

# 8. Настраиваем dnsmasq - НЕ ЗАБУДЬТЕ ПРАВИЛЬНЫЕ НАСТРОЙКИ!
sudo tee /etc/dnsmasq.conf << 'EOF'
interface=ens19
#bind-interfaces
#listen-address=192.168.5.171            # Слушаем на СВОЁМ IP
#listen-address=192.168.5.1
server=8.8.8.8
server=1.1.1.1
dhcp-range=192.168.5.170,192.168.5.199,24h
dhcp-option=3,192.168.5.1               # ШЛЮЗ - ВИРТУАЛЬНЫЙ IP!
dhcp-option=6,192.168.5.171,192.168.5.172  # Два DNS сервера
log-queries
log-dhcp
no-resolv
bind-dynamic
EOF

# 9. Включаем и запускаем службы
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

# 10. Настраиваем Keepalived (ОТКАЗОУСТОЙЧИВОСТЬ!)
sudo tee /etc/keepalived/keepalived.conf << 'EOF'
! Configuration File for keepalived

global_defs {
    router_id ROUTER1_MASTER
}

# LAN VIP — шлюз для клиентов
vrrp_instance LAN {
    state MASTER
    interface ens19
    virtual_router_id 51
    priority 150
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass maxomsk
    }
    
    virtual_ipaddress {
        192.168.5.1/24 dev ens19
    }
    
    track_interface {
        ens18
        ens19
    }
}

# WAN VIP — для входящих подключений
vrrp_instance WAN {
    state MASTER
    interface ens18
    virtual_router_id 52
    priority 150
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass maxomsk
    }
    
    virtual_ipaddress {
        192.168.10.1/24 dev ens18
    }
    
    track_interface {
        ens18
    }
}
EOF

# 11. Включаем Keepalived
sudo systemctl enable keepalived
sudo systemctl start keepalived

# 12. Отключаем systemd-resolved (чтобы не мешал dnsmasq)
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# 13. Автозагрузка iptables правил (уже есть в вашем скрипте)
sudo tee /etc/systemd/system/iptables-boot.service << 'EOF'
[Unit]
Description=Load iptables rules at boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable iptables-boot.service

echo "=== Настройка ПЕРВОГО роутера завершена! ==="
echo "=== ПРОВЕРКИ ==="
echo "1. Сетевые интерфейсы:"
ip addr show | grep -E "ens|inet "

echo -e "\n2. Keepalived статус:"
sudo systemctl status keepalived --no-pager -l

echo -e "\n3. Виртуальный IP (должен появиться только на MASTER):"
ip addr show | grep "192.168.5.1" || echo "Виртуальный IP отсутствует (это нормально для BACKUP)"

echo -e "\n4. Проверка связи:"
ping -c 2 8.8.8.8
ping -c 2 192.168.5.172

echo -e "\n=== ИНСТРУКЦИЯ ==="
echo "1. На основном роутере (192.168.5.171) настройте Keepalived как MASTER:"
echo "   state MASTER, priority 150, тот же virtual_router_id (51) и пароль"
echo "2. Проверьте, что на основном роутере появился виртуальный IP 192.168.5.1"
echo "3. В DHCP на обоих роутерах укажите шлюзом 192.168.5.1"
echo "4. Отключите основной роутер - второй должен взять виртуальный IP"
