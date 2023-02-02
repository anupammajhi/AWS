#!/usr/bin/env bash

## Author: Anupam Majhi
## Github: https://github.com/anupammajhi/AWS
## Description: This script generates a report of mounted ebs volumes and partitions to an EC2 instance. It includes EBS Volume Device name, Mapping to the instance, the filesystem and mountpoints to the instance along with disk capacity information.

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
  echo "Usage: ebs_capacity_monitor"
  echo ""
  echo "This script generates a report of mounted ebs volumes and partitions to an EC2 instance. It includes EBS Volume Device name, Mapping to the instance, the filesystem and mountpoints to the instance along with disk capacity information."
  echo ""
  echo "The script takes no arguments. To run the script, simply type './ebs_capacity_monitor.sh'"
  exit 0
fi

alert_threshold=75

file_out="/mnt/EBSMonitor/logs/EBS_CAPACITY_CHECK_$(date +%Y-%m-%d-%H-%M-%S).txt"
html_out="/mnt/EBSMonitor/logs/EBS_CAPACITY_CHECK_$(date +%Y-%m-%d-%H-%M-%S).html"
awk_template="/mnt/EBSMonitor/logs/ebs_template.awk"

echo "=========== Script started ==========="

blk_dev_map=`curl -s http://169.254.169.254/latest/meta-data/block-device-mapping`

not_ebs_dev=("root" "swap")

for dmap in ${blk_dev_map[@]}
do    
    if [[ ! $dmap == "swap" ]] && [[ ! $dmap == *"ephemeral"* ]] && [[ ! $dmap == "root" ]]; then
        

        blk_dev_name=`curl -s http://169.254.169.254/latest/meta-data/block-device-mapping/$dmap`
        if [[ ! $blk_dev_name == "/dev/"* ]]; then
            blk_dev_name="/dev/$blk_dev_name"
        fi
        

        fs_name=`readlink -f $blk_dev_name`

        fs_knames=`lsblk $fs_name --output=kname | sed 1d`
        fs_ebs_sizes=`lsblk $fs_name --output=size | sed 1d`

        for kn in $fs_knames
        do  
            fs_mp=`lsblk /dev/$kn --output=mountpoint | sed 1d`
            if [[ $fs_mp == "/"* ]]; then
                alert="OK"
                fs_kname=$kn
                fs_ebs_size=`lsblk $fs_name -d --output=size | sed 1d`

                cap_pcent=`df -h /dev/$fs_kname --output=pcent | sed 1d`
                ebs_pcent+=( $cap_pcent )

                cap_size=`df -h /dev/$fs_kname --output=size | sed 1d`
                ebs_fs_size+=( $cap_size )

                cap_avail=`df -h /dev/$fs_kname --output=avail | sed 1d`
                ebs_avail+=( $cap_avail )

                cap_target=`df -h /dev/$fs_kname --output=target | sed 1d`
                ebs_target+=( $cap_target )

                ebs_dev_name+=( $blk_dev_name )

                ebs_fs+=( "/dev/$fs_kname" )

                ebs_dev+=( $dmap )

                ebs_size+=( $fs_ebs_size )

                cap_pcent_num=`echo $cap_pcent | grep -o -P '[0-9]*(\.[0-9]*)?(?=%)'`
                cap_pcent_num="${cap_pcent_num//[$'\t\r\n ']}"

                if [ $cap_pcent_num -ge $alert_threshold ];then
                    alert="!!_ALERT_!!"
                fi
                comment+=( $alert ) 

            fi
        done
    fi
    
done

paste <(printf '%s\n' Device_Name "${ebs_dev_name[@]}") \
      <(printf '%s\n' EBS_Mapping "${ebs_dev[@]}") \
      <(printf '%s\n' Filesystem "${ebs_fs[@]}") \
      <(printf '%s\n' EBS_Size "${ebs_size[@]}") \
      <(printf '%s\n' Partition_Size "${ebs_fs_size[@]}") \
      <(printf '%s\n' Available "${ebs_avail[@]}") \
      <(printf '%s\n' Used% "${ebs_pcent[@]}") \
      <(printf '%s\n' Mountpoint "${ebs_target[@]}") \
      <(printf '%s\n' Comment "${comment[@]}") \
| column -ts $'\t' > $file_out

cat $file_out

#===========================================================================

cat > $awk_template <<'endmsg'
BEGIN {
    print "<table  border=\"1\" cellpadding=\"3\"  style=\"border-collapse: collapse\">"

    print "<tr>"
    print "<th bgcolor=LightBlue colspan="9">EBS Volumes and Partitions</th>"
    print "</tr>"
    print "<tr>"
    print "<th bgcolor=LightCyan>Device_Name</th>"
    print "<th bgcolor=LightCyan>EBS_Mapping</th>"
    print "<th bgcolor=LightCyan>Filesystem</th>"
    print "<th bgcolor=LightCyan>EBS_Size</th>"
    print "<th bgcolor=LightCyan>Partition_Size</th>"
    print "<th bgcolor=LightCyan>Available</th>"
    print "<th bgcolor=LightCyan>Used%</th>"
    print "<th bgcolor=LightCyan>Mountpoint</th>"
    print "<th bgcolor=LightCyan>Comment</th>"
    print "</tr>"
}

NR > 1 {
    bgcolor=""
    if ($9 == "!!_ALERT_!!") {
        bgcolor=" bgcolor=Tomato"
    }
    print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td><td>"$7"</td><td>"$8"</td><td"bgcolor">"$9"</td></tr>"
}

END {
    print "</table>"
}
endmsg

status_msg="All Volumes are have more than $(( 100 - $alert_threshold ))% free space"
if [[ `cat $file_out` == *"_ALERT_"* ]];then
    status_msg="Some or all Volumes may have less than $(( 100 - $alert_threshold ))% free space"
fi

echo '<p style="text-align:center"><u><strong><span style="font-size:24px">EBS Volume Capacity Report</span></strong></u></p>'  > $html_out
echo "<p style='text-align:center'><span style='font-size:18px'>Report Generated on: $(date +%Y-%m-%d_%H:%M:%S) (UTC)</span></p>"     >> $html_out
echo '<p style="text-align:center">&nbsp;</p>'                                                                                  >> $html_out
echo "<p><span style='font-size:14px'>Note: The threshold is set at ${alert_threshold}%</span></p>"                             >> $html_out
echo "<p><span style='font-size:24px'>Status: $status_msg</span></p>"                                                           >> $html_out
echo '<hr />'                                                                                                                   >> $html_out
echo '<p style="text-align:center">&nbsp;</p>'                                                                                  >> $html_out
cat $file_out | awk -f $awk_template                                                                                            >> $html_out


echo "=========== Script completed ==========="

echo $html_out
echo $file_out
