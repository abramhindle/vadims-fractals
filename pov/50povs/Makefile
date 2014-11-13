.SUFFIXES: .pov .png

POVS=$(shell ls *.pov)
PNGS:= $(subst .pov,.png,$(POVS))

.pov.png:
	povray -d $<

test:
	echo $(POVS)
	echo $(PNGS)

all: $(PNGS)
	echo 
