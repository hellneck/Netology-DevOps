#!/bin/bash

docker run -d --name=fedora --rm pycontribs/fedora:latest sleep 1000
docker run -d --name=centos7 --rm pycontribs/centos:7 sleep 1000
docker run -d --name=ubuntu --rm pycontribs/ubuntu:latest sleep 1000

ansible-playbook site.yml -i inventory/prod.yml

docker stop fedora centos7 ubuntu