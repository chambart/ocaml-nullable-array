COMPILE_ARG=-g -bin-annot -annot -keep-locs -w +a-37 -warn-error +a
COMPILE_OPT_ARG=$(COMPILE_ARG)

all: natdynlink

byte: lib/nullable_array.cma
native: lib/nullable_array.cmxa byte
natdynlink: lib/nullable_array.cmxs native

lib/nullable_array.cmi: lib/nullable_array.mli
	ocamlc $(COMPILE_ARG) -c $< -o $@

lib/nullable_array.cmo: lib/nullable_array.ml lib/nullable_array.cmi
	ocamlc $(COMPILE_ARG) -I lib -c $< -o $@

lib/nullable_array.cmx: lib/nullable_array.ml lib/nullable_array.cmi
	ocamlopt $(COMPILE_OPT_ARG) -I lib -c $< -o $@

lib/nullable_array.cmxa: lib/nullable_array.cmx
	ocamlopt $(COMPILE_OPT_ARG) -I lib -a $? -o $@

lib/nullable_array.cmxs: lib/nullable_array.cmx
	ocamlopt $(COMPILE_OPT_ARG) -I lib -shared $? -o $@

lib/nullable_array.cma: lib/nullable_array.cmo
	ocamlc $(COMPILE_ARG) -I lib -a $? -o $@

clean::
	rm -f lib/*.a lib/*.o lib/*.cma lib/*.cmo lib/*.cmx lib/*.cmi \
	      lib/*.cmxa lib/*.cmxs lib/*.cmt lib/*.cmti lib/*.annot

TEST_COMPILE_ARG=-I lib -I test -w +a

test: test_native

test_byte: test/basic.byte
test_native: test_byte test/basic.opt

test/basic.byte: test/basic.mli test/basic.ml byte
	ocamlc $(TEST_COMPILE_ARG) lib/nullable_array.cma test/basic.mli test/basic.ml -o $@
	$@

test/basic.opt: test/basic.ml native
	ocamlopt $(TEST_COMPILE_ARG) lib/nullable_array.cmxa test/basic.mli test/basic.ml -o $@
	$@

clean::
	rm -f test/*.a test/*.o test/*.cma test/*.cmo test/*.cmx test/*.cmi \
	      test/*.cmxa test/*.cmxs test/*.cmt test/*.cmti test/*.annot \
	      test/*.byte test/*.opt

install:
	ocamlfind install nullable_array META \
	  lib/*.a lib/*.o lib/*.cma lib/*.cmo lib/*.cmx lib/*.cmi \
	  lib/*.cmxa lib/*.cmxs lib/*.cmt lib/*.cmti lib/*.annot

uninstall:
	ocamlfind remove nullable_array

.PHONY: all install uninstall clean
