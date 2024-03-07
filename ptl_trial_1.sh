#!/bin/bash

source /etc/profile
module load julia/1.9.2
module load gurobi/gurobi-1000

# julia --project=. fusion_paper/paper_runs/dual_runs/final_report_runs/final_basecase/Run.jl $LLSUB_RANK $LLSUB_SIZE 16