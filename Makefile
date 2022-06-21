.DEFAULT_GOAL := start

vagrant:
	vagrant up

unvagrant:
	vagrant destroy -f

fw:
	vagrant push

unfw:
	rm -rf local/gitfw

start: vagrant fw

stop: unvagrant unfw