.DEFAULT_GOAL := start

.PHONY: vagrant unvagrant fw unfw

vagrant:
	vagrant up

unvagrant:
	vagrant destroy -f

local/gitfw:
	vagrant push

fw: local/gitfw
	
unfw:
	rm -rf local/gitfw

start: vagrant fw

stop: unvagrant unfw