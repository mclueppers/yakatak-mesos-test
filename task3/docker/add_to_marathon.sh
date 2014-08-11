#!/bin/bash



curl -X POST -H "Content-Type: application/json" 192.168.50.10:8080/v2/apps -d@$1
