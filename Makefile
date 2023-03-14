DP = vldrdy_distributor

sim: $(DP)/code/*
	cd $(DP) && vcs -f ./filelist.f -full64 -sverilog -debug_acc+all

run: $(DP)/simv
	$(DP)/simv

f: 
	cd $(DP) && touch filelist.f && (find -name "*.sv" > filelist.f)

.DEFAULT_GOAL := all
.PHONY : all f
all : sim run