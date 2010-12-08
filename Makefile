all_bets: *.hs
	ghc --make -o $@ all_bets.hs

clean:
	rm -f all_bets *.o *.hi
.PHONY: clean

