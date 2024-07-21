#!/bin/bash

cat /sys/bus/pci/devices/0000\:*/i915.mei*/mei/mei*/fw_ver | sort | uniq
rpm -qa | grep intel
grep __INTEL_MKL_BUILD_DATE $MKLROOT/include/mkl_version.h
ze_info | grep "Driver Version"
icpx --version | head  -n 1

