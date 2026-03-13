# 🚀 Моя DevOps лаборатория

Цель: изучить современные DevOps практики на реальной инфраструктуре.

## 🏗️ Инфраструктура

🌐 Сеть

    Шлюз в интернет: MikroTik 192.168.10.1

    Локальная сеть: 192.168.5.0/24
<img width="1722" height="679" alt="Screenshot From 2026-03-13 17-13-27" src="https://github.com/user-attachments/assets/44df202b-d2fa-4455-98c1-39cc3147f524" />



🖥️ Инфраструктура (всё крутится на Proxmox)

🧱 Гипервизоры (Proxmox Cluster)

    pve1 · 192.168.5.151

    pve2 · 192.168.5.152

    pve3 · 192.168.5.153

    PBS · 192.168.5.160 — выделенный сервер бекапов

На этом кластере запущены все виртуальные машины, включая роутеры, хранилище и сервисы.
📦 Виртуальные машины (на Proxmox)
🔁 Роутеры (отказоустойчивая связка)

    router1 · Ubuntu · 192.168.5.171
    → основной DHCP/DNS-сервер

    router2 · Ubuntu · 192.168.5.172
    → резервный DHCP/DNS (keepalived + dhcpd)

📊 Мониторинг

    Zabbix · Ubuntu · 192.168.5.102
    → централизованный мониторинг всей инфраструктуры

💾 Хранилище и бекапы

    TrueNAS · 192.168.5.200
    → сетевое хранилище (NFS / SMB) для всех VM

    PBS · 192.168.5.160
    → бекапы Proxmox и виртуальных машин

## 🎯 Текущие задачи
1. Настройка мониторинга (Prometheus, Grafana, Alertmanager)
2. Создание отказоустойчивой БД MySQL с репликацией
3. Развертывание Docker-приложений
4. Автоматизация через Ansible и Terraform

## 📚 Изучаемые технологии


|      Статус          | Технология       | Прогресc |      Что умею        |
|--------------------- |----------------- |--------- |----------------------|
| 🟩🟩🟩⬜⬜⬜⬜⬜⬜⬜ | 🐍 Ansible       | 30%      | плейбуки, vault, роли|
| ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ | 🏗️ Terraform     | 0%       | в процессе           |
| 🟩🟩🟩⬜⬜⬜⬜⬜⬜⬜ | 🐳 Docker        | 30%      | контейнеры, compose  |
| ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ | ☸️ Kubernetes     | 0%       | в процессе           |
| 🟩🟩⬜⬜⬜⬜⬜⬜⬜⬜ | 🔄 GitLab CI/CD  | 15%      | базовые пайплайны    |
| 🟩⬜⬜⬜⬜⬜⬜⬜⬜⬜ | 📊 Prometheus    | 10%      | знакомство с забиксом|


## 🛠️ Быстрые команды
```bash
# Проверить доступность всех нод
ansible all -i inventory.yml -m ping

# Проверить uptime
ansible all -i inventory.yml -m shell -a "uptime"

# Собрать информацию об ОС
ansible all -i inventory.yml -m setup -a "filter=ansible_distribution*"

# Проверить бекапы на районах
rclone ls maxomskaoe:maxomskaoe/ | grep $(date -d "yesterday" +%Y-%m-%d) 
check_backup # alias
# Git Alias
git acp

# Подключить pppoe
sudo pon dsl-provider
# Отключить pppoe
sudo poff
# Windows host default powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
