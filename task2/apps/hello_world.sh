#!/bin/bash
HOST=$1
PORT=$2

# Dirty way to ping our Docker application
echo Hello world | nc ${HOST} ${PORT}
