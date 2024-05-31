#!/usr/bin/env bash

ENV_FILE=${HOME}/.env

if [ "$#" -eq 0 ]; then
	echo "Environment Key is required. Please provide the environment key as the first argument"
	exit -1
fi

ENV_KEY=$1

grep "${ENV_KEY}" ${ENV_FILE} | cut -d '=' -f2
