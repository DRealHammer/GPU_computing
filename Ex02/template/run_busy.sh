module load cuda/11.2

make

for clock_num in $(seq 1 100 100000)
do
    sbatch busy.sh $clock_num
done