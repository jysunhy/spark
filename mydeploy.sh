#!/bin/bash
set -eux                                                                                                             
set -o pipefail

slaves="h0 h1 h2 h3"
master="spark://h620:7077"

function build(){
	./make-distribution.sh --skip-java-test --name dissp --tgz
}

function stop_slaves(){
	echo "Stopping slaves"
	script="spark-1.6.1-SNAPSHOT-bin-dissp/sbin/stop-slave.sh"
	for slave in $slaves
	do
		ssh user@$slave $script >> deploy_$slave.log 2>&1 
	done
}

function stop_master(){
	echo "Stopping master"
	./sbin/stop-master.sh
}

function start_master(){
	echo "Starting master"
	./sbin/start-master.sh
}

function install_slaves(){
	echo "Installing and starting slaves"
	script="tar xvf spark-1.6.1-SNAPSHOT-bin-dissp.tgz; spark-1.6.1-SNAPSHOT-bin-dissp/sbin/start-slave.sh "$master
	for slave in $slaves
	do
		scp ./spark-1.6.1-SNAPSHOT-bin-dissp.tgz user@$slave:~/
		ssh user@$slave $script >> deploy_$slave.log 2>&1 
	done
}

#build()
stop_slaves
stop_master
start_master
install_slaves
