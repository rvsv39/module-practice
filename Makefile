DP = vldrdy_distributor

sim: $(DP)/code/*
	cd $(DP) && vcs -f ./filelist.f -full64 -sverilog -debug_acc+all

run: $(DP)/simv
	$(DP)/simv

.DEFAULT_GOAL := all
.PHONY : all
all : sim run