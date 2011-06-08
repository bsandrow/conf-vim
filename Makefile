prefix ?= $(HOME)

.PHONY: default copy install

default: install

copy:
	cp -r gvimrc vimrc vim $(prefix)/

install:
	install -d -m 755 $(prefix)
	install -m 644 gvimrc $(prefix)/.gvimrc
	install -m 644 vimrc  $(prefix)/.vimrc
	cp -r vim/. $(prefix)/.vim && chmod 755 $(prefix)/.vim
