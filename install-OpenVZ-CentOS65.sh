#!/bin/bash

# BASH guard
if ! [ -n "$BASH_VERSION" ];then
    echo "this is not bash, calling self with bash....";
    SCRIPT=$(readlink -f "$0")
    /bin/bash $SCRIPT
    exit;
fi

clear
echo 'Pemasangan OpenVZ...'

echo "Memperbarui program..."
yum update -y

echo 'pemasangan wget...'
yum install wget -y

echo 'Penambahan OpenVZ Repositori...'
cd /etc/yum.repos.d
wget http://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ

echo 'Pemasangan OpenVZ Kernel...'
yum install -y vzkernel

echo 'Pemasangan peralatan yang dibutuhkan...'
yum install vzctl vzquota ploop -y

echo 'Mengubah konfigurasi file...'
sed -i 's/kernel.sysrq = 0/kernel.sysrq = 1/g' /etc/sysctl.conf

echo "Pengaturan penerusan paket..."
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

echo "Memungkinkan banyak subnet dalam satu interface jaringan yang sama..."
sed -i 's/#NEIGHBOUR_DEVS=all/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf
sed -i 's/NEIGHBOUR_DEVS=detect/NEIGHBOUR_DEVS=all/g' /etc/vz/vz.conf

echo "Pengaturan layout container bawaan ke model ploop..."
sed -i 's/#VE_LAYOUT=ploop/VE_LAYOUT=ploop/g' /etc/vz/vz.conf

echo "Pengaturan Ubuntu 12.04 64bit sebagai template bawaan..."
sed -i 's/centos-6-x86/ubuntu-12.04-x86_64/g' /etc/vz/vz.conf

echo 'Pembersihan sys config file...'
sysctl -p

echo "Menonaktifkan selinux..."
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "Menonaktifkan iptables..."
/etc/init.d/iptables stop && chkconfig iptables off

clear

echo "OpenVZ telah terpasang... "
echo "Muat ulang untuk mulai menggunakan OpenVZ..."
