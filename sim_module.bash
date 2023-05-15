#!/bin/bash

#SBATCH -N 20
#SBATCH --ntasks-per-node=40
#SBATCH -t 20:00:00
#SBATCH --job-name gnu-parallel-fork
#SBATCH -o /scratch/o/oespinga/kmin940/autism/sim_module.out

### first arg is output directory name under $SCRATCH/autism/
### second arg is replicate numbers
### third arg is nfam

export OMP_NUM_THREADS=1

module load intel/2019u4 r/4.1.2 gcc/8.3.0
module load gnu-parallel/20191122

export CODE_DIR="$HOME/autism/scripts"
export OUT_DR="$SCRATCH/autism/"$1

if test $# -ne 4
then
        echo "usage: sim_module.bash out_dir num_replicates nfam param_rdata"
        exit 1
fi

mkdir -p $OUT_DR
export replicates=$(($2-1))
export nfam=$3
export para=$4

echo $nfam
echo $3
echo $PWD
#cd $OUT_DR
#parallel echo {} ::: `seq 0 $replicates`
parallel --env CODE_DIR,OUT_DR,nfam,replicates --wd $OUT_DR --jobs 10 'R CMD BATCH --no-restore --no-save "--args param_file=\"${para}\" datanum={} n.fam=${nfam} outdir=\"${OUT_DR}\"" ${CODE_DIR}/sim_module.R ${OUT_DR}/log{}.Rout' ::: `seq 0 $replicates`

#for i in `seq 0 $replicates` ; do
#        srun --exclusive -c 1 -n 1 -t 01:00:00 R CMD BATCH "--args datanum=${1} n.fam=${3} outdir=\"${OUT_DR}\"" ${CODE_DIR}/sim.R ${OUT_DR}/log${i}.Rout &
#done
#wait

echo "done"
