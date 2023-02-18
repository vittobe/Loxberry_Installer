#!/bin/bash

if [ ! -e '/boot/dietpi/.hw_model' ]; then
	echo -e "\nThis benchmark can only be run on DietPi\n"
	exit 1
fi

echo ""
echo "Quick'n'Dirty LoxBerry Benchmarking Tool" | tee benchmark.log
echo "https://www.heise.de/hintergrund/Benchmarks-fuer-Single-Board-Computer-4850569.html" | tee -a benchmark.log

echo -e "\nInstalling additional software...\n"

apt-get install p7zip-full iozone3 mbw openssl colorized-logs

echo -e "\nGrabbing some information about the system we are running on...\n" | tee -a benchmark.log

uname -a | tee -a benchmark.log

echo "" | tee -a benchmark.log

cat /boot/dietpi/.hw_model | tee -a benchmark.log

echo "" | tee -a benchmark.log

/boot/dietpi/dietpi-cpuinfo | ansi2txt | tee -a benchmark.log

echo -e "\nPerforming DietPi Benchmark\n" | tee -a benchmark.log

G_INTERACTIVE=0 /boot/dietpi/func/dietpi-benchmark 2 | ansi2txt | tee -a benchmark.log

echo "" | tee -a benchmark.log

cat /var/lib/dietpi/dietpi-benchmark/results | tee -a benchmark.log

echo -e "\nPerforming iozone Benchmark\n" | tee -a benchmark.log

iozone -e -I -a -s 100M -r 16384k -i 0 -i 1 -i 2 | tee -a benchmark.log

echo -e "\nPerforming 7-Zip Benchmark\n" | tee -a benchmark.log

7z b | tee -a benchmark.log

echo -e "\nPerforming MBW Benchmark\n" | tee -a benchmark.log

mbw 100 | tee -a benchmark.log

echo -e "\nPerforming OpenSSL Benchmark\n" | tee -a benchmark.log

openssl speed -elapsed aes-128-cbc | tee -a benchmark.log


echo "" | tee -a benchmark.log

echo "Full results can be viewed here:"
cat benchmark.log | curl -F 'f:1=<-' ix.io

echo ""

exit 0
