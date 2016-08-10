#!/bin/python3
import sys
import os
import tempfile
import pprint
import logging
from logging import debug, info, warning, error

def process_info(line):
    line = line.strip()
    arr = line.split(':')
    if len(arr) < 2:
        return None, None
    key = arr[0]
    val = None
    if key == "freq":
        val = "{}Hz".format(arr[1].strip())
    elif key == "signal":
        val = "{}%".format(100 + int(float(arr[1].split()[0])))
    elif key == "SSID":
        val = arr[1].strip()
    elif key == 'WPA':
        val = True
    elif key == "RSN":
        val = True
    elif key == "capability" and "Privacy" in arr[1]:
        key = "Privacy"
        val = True
    return key, val

def print_scan(bsss):
    for bss in bsss:
        info = bsss[bss]
        print("{} {}: ssid     : {}".format("*" if "associated" in info
                                            else " ",
                                            bss,
                                            info["SSID"]))
        print("                     signal   : {}".format(info["signal"]))
        print("                     freq     : {}".format(info["freq"]))
        print("                     security : {}".format(
            "WPA2" if info.get("RSN", False) else
            "WPA" if info.get("WPA", False) else
            "WEP" if info.get("Privacy", False) else
            "None"))

def main():
    wifi_if = "wlp8s0"
    if len(sys.argv) == 2:
        wifi_if = sys.argv[1]
    iw_out = tempfile.mktemp(suffix="iw", prefix="scan_wifi")
    debug("iw output file: {}".format(iw_out))
    r = os.system("sudo iw dev {} scan > {}".format(wifi_if, iw_out))
    if r:
        error("Error when scanning {}".format(wifi_if))
        sys.exit(1)
    f = open(iw_out, 'r')
    bsss = dict()
    for line in f.readlines():
        if line.startswith("BSS "):
            cur_bss = line[4:21]
            bsss[cur_bss] = dict()
            if line.endswith("associated\n"):
                bsss[cur_bss]["associated"] = True
        elif not cur_bss:
            error("Not assosied BSS for cureent line: {}".format(line))
            continue
        else:
            key, val = process_info(line)
            if key and val:
                bsss[cur_bss][key] = val

    print_scan(bsss)
    os.remove(iw_out)

if __name__ == "__main__":
    # logging.basicConfig(level=logging.DEBUG)
    main()
