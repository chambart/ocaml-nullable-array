COMPILE_ARG=-g -bin-annot -annot -keep-locs
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


install:
	ocamlfind install nullable_array META \
	  lib/*.a lib/*.o lib/*.cma lib/*.cmo lib/*.cmx lib/*.cmi \
	  lib/*.cmxa lib/*.cmxs lib/*.cmt lib/*.cmti lib/*.annot

uninstall:
	ocamlfind remove nullable_array

clean:
	rm -f lib/*.a lib/*.o lib/*.cma lib/*.cmo lib/*.cmx lib/*.cmi \
	      lib/*.cmxa lib/*.cmxs lib/*.cmt lib/*.cmti lib/*.annot

.PHONY: all install uninstall clean
