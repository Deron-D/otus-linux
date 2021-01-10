#!/bin/bash
nmap -Pn --host-timeout 100 --max-retries 0 -p 8881 192.168.255.1
nmap -Pn --host-timeout 100 --max-retries 0 -p 7777 192.168.255.1
nmap -Pn --host-timeout 100 --max-retries 0 -p 9991 192.168.255.1
ssh -o StrictHostKeyChecking=no vagrant@192.168.255.1
