WORKERS = combination combine

all: $(WORKERS)

combination: combination.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

combine: combine.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

clean:
	rm -f combination combine *.o *.hi
.PHONY: clean

