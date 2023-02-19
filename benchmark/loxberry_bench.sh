#!/bin/bash

CheckLoad() {
	AvgLoad1Min=$(awk -F" " '{print $1*100}' < /proc/loadavg)
	if [ $AvgLoad1Min -ge 10 ]; then
		echo -e "\nAverage load and/or CPU utilization too high (too much background activity). Waiting...\n"
		while [ $AvgLoad1Min -ge 20 ]; do
			sleep 5
			echo -e "Too busy for benchmarking:$(uptime)"
			AvgLoad1Min=$(awk -F" " '{print $1*100}' < /proc/loadavg)
		done
		echo ""
	fi
} # CheckLoad

if [ ! -e '/boot/dietpi/.hw_model' ]; then
	echo -e "\nThis benchmark can only be run on DietPi\n"
	exit 1
else
	. /boot/dietpi/.hw_model
fi

echo ""
echo "Quick'n'Dirty LoxBerry Benchmarking Tool" | tee benchmark.log
echo "https://www.heise.de/hintergrund/Benchmarks-fuer-Single-Board-Computer-4850569.html" | tee -a benchmark.log

echo -e "\nInstalling additional software...\n"

apt-get -y install p7zip-full mbw openssl colorized-logs dnsutils dmidecode file bluez hddtemp net-tools ipmitool freeipmi-tools lvm2 mdadm lm-sensors smartmontools tree upower libio-socket-ssl-perl libcpanel-json-xs-perl libjson-xs-perl libxml-dumper-perl inxi

if [[ $G_RASPBIAN -eq "1" ]] && [[ ! -e '/usr/local/bin/iozone' ]]; then
	rm /tmp/iozone
	wget https://raw.githubusercontent.com/mschlenstedt/Loxberry_Installer/main/benchmark/iozone -O /usr/local/bin/iozone
	chmod +x /usr/local/bin/iozone
else
	apt-get -y install iozone3
fi

echo -e "\nGrabbing some information about the system we are running on...\n" | tee -a benchmark.log

uname -a | tee -a benchmark.log

echo "" | tee -a benchmark.log

cat /boot/dietpi/.hw_model | tee -a benchmark.log

echo "" | tee -a benchmark.log

/boot/dietpi/dietpi-cpuinfo | ansi2txt | tee -a benchmark.log

echo "" | tee -a benchmark.log

inxi -Fc0 | tee benchmark.log

echo "" | tee -a benchmark.log

CheckLoad
echo -e "\nPerforming DietPi Benchmark\n" | tee -a benchmark.log

G_INTERACTIVE=0 /boot/dietpi/func/dietpi-benchmark 2 | ansi2txt | tee -a benchmark.log

echo "" | tee -a benchmark.log

cat /var/lib/dietpi/dietpi-benchmark/results | tee -a benchmark.log

CheckLoad
echo -e "\nPerforming iozone Benchmark\n" | tee -a benchmark.log

iozone -e -I -a -s 100M -r 16384k -i 0 -i 1 -i 2 | tee -a benchmark.log

CheckLoad
echo -e "\nPerforming 7-Zip Benchmark\n" | tee -a benchmark.log

7z b | tee -a benchmark.log

CheckLoad
echo -e "\nPerforming MBW Benchmark\n" | tee -a benchmark.log

mbw 100 | tee -a benchmark.log

CheckLoad
echo -e "\nPerforming OpenSSL Benchmark\n" | tee -a benchmark.log

openssl speed -elapsed aes-128-cbc | tee -a benchmark.log

echo "" | tee -a benchmark.log
sleep 2

echo "Full results can be viewed here:"
cat benchmark.log | ansi2txt | curl -F 'f:1=<-' ix.io

echo ""

exit 0
