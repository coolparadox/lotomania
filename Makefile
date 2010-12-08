all: all_bets rank_bets sort_by_rank

all_bets: *.hs
	ghc --make -o $@ all_bets.hs

rank_bets: *.hs
	ghc --make -o $@ rank_bets.hs

sort_by_rank: sort_by_rank.sh
	rm -f $@
	ln -s $< $@

clean:
	rm -f all_bets rank_bets sort_by_rank *.o *.hi
.PHONY: clean

