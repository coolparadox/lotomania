WORKERS = combination combine random_value vgrep comb_bet_step bet_step bet_template make_template_file bets sort_bets

all: $(WORKERS)

combination: combination.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

combine: combine.hs CombAnal.hs Natural.hs
	ghc --make -o $@ $<

random_value: random_value.hs
	ghc --make -o $@ $<

vgrep: vgrep.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

comb_bet_step: comb_bet_step.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

bet_step: bet_step.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

bet_template: bet_template.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

make_template_file: make_template_file.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

bets: bets.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

sort_bets: sort_bets.sh
	rm -f $@
	ln -s $< $@
	chmod a+x $@

clean:
	rm -f combination combine random_value vgrep comb_bet_step bet_step bet_template make_template_file bets sort_bets *.o *.hi
.PHONY: clean

