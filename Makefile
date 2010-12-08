all: all_bets rank_bets

all_bets: *.hs
	ghc --make -o $@ all_bets.hs

rank_bets: *.hs
	ghc --make -o $@ rank_bets.hs

clean:
	rm -f all_bets rank_bets *.o *.hi
.PHONY: clean

