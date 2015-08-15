#!/bin/bash
if [ "$1" = "NONE" ]; then
    echo "Usage: sudo docker run -it --rm -v ~/samples:/samples:ro -v ~/samples/out/:/samples/out honeynet/droidbox /samples/filename.apk [duration in seconds]"
    exit 1
fi
echo -e "\e[1;32;40mDroidbox Docker starting\nWaiting for the emulator to startup..."
mkdir -p /samples/out/$3
/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' > /samples/out/$3/ip.txt
sleep 1
/opt/android-sdk-linux/tools/emulator64-arm @droidbox -no-window -no-audio -system /opt/DroidBox_4.1.1/images/system.img -ramdisk /opt/DroidBox_4.1.1/images/ramdisk.img  -tcpdump /samples/out/emu1.pcap >> /samples/out/$3/emulator.log &
sleep 1
service ssh start
adb wait-for-device 
adb forward tcp:5900 tcp:5901
adb shell /data/fastdroid-vnc >> /samples/out/$3/vnc.log &
echo -ne "\e[0m"
adb get-state
python /opt/DroidDocker/scripts/droidbox.py $1 $2 2>&1 |tee /samples/out/$3/analysis.log
echo -ne "\e[0m"
exit
