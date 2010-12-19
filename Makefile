WORKERS = combine rank_bets sort_by_rank generate_bets

all: $(WORKERS)

dupla_sena.bz2: $(WORKERS)
	./combine 50 6 | ./rank_bets 50 | ./sort_by_rank | bzip2 --best -c 1>$@

lotomania.bz2: $(WORKERS)
	./combine 100 50 | ./rank_bets 100 | ./sort_by_rank | bzip2 --best -c 1>$@

combine: *.hs
	ghc --make -o $@ combine.hs

rank_bets: *.hs
	ghc --make -o $@ rank_bets.hs

generate_bets: *.hs
	ghc --make -o $@ generate_bets.hs

sort_by_rank: sort_by_rank.sh
	rm -f $@
	ln -s $< $@

clean:
	rm -f combine rank_bets generate_bets sort_by_rank *.o *.hi
.PHONY: clean

