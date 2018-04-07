%.bash : %.bash.in
	echo "#"                                        >$@
	echo "# This file was auto generated from $<." >>$@
	echo "# Do not edit directly this file."       >>$@
	echo "#"                                       >>$@
	echo                                           >>$@
	cat $<                                         >>$@

TARGETS = \
	hhs_all.bash

all: $(TARGETS)

clean: $(TARGETS)
	-$(RM) $<