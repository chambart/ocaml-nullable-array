INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)

# Default rule
default:
	dune build @install

test:
	dune runtest

dev:
	dune build

install:
	dune install $(INSTALL_ARGS)

uninstall:
	jbuilder uninstall $(INSTALL_ARGS)

reinstall: uninstall reinstall

clean:
	dune clean

doc:
	dune build @doc

.PHONY: default test dev install uninstall reinstall clean doc
