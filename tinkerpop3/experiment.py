#!/usr/bin/python
import subprocess
import time

def run_cmd(cmd):
	p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	while p.poll() is None:
		line = p.stdout.readline()
		line = line.strip()
		if line:
			print(line)


def run(threads_count, operation_count):
#	run_cmd("sudo -E ./load-scripts/delete-neo4j-database.sh")
	print("Delete database done.")
#	run_cmd("sudo -E ./load-scripts/import-to-neo4j.sh")
	print("Import data done.")
#	run_cmd("sudo -E ./load-scripts/restart-neo4j.sh")
	print("Restart neo4j done.")
#	time.sleep(20)  #wait for neo4j ready
	cmd = "java -cp target/tinkerpop3-0.0.1-SNAPSHOT.jar com.ldbc.driver.Client -P interactive-benchmark.properties -rd result/result-t{}-oc{}-newconf -tc {} -oc {}".format(threads_count, operation_count, threads_count,operation_count)
	run_cmd(cmd)

#threads_count = [1, 2, 4, 8, 16]
threads_count = [1]
operation_count = 5
for tc in threads_count:
	run(tc, operation_count)

