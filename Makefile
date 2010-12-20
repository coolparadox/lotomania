WORKERS = combination combine random_value

all: $(WORKERS)

combination: combination.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

combine: combine.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

random_value: random_value.hs
	ghc --make -o $@ $<

clean:
	rm -f combination combine random_value *.o *.hi
.PHONY: clean

