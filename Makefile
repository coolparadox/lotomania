WORKERS = combination combine random_value comb_bet_step bet_step bets

all: $(WORKERS)

combination: combination.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

combine: combine.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

random_value: random_value.hs
	ghc --make -o $@ $<

comb_bet_step: comb_bet_step.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

bet_step: bet_step.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

bets: bets.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

clean:
	rm -f combination combine random_value comb_bet_step bet_step bets *.o *.hi
.PHONY: clean

