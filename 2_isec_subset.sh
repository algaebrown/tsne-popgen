#!/bin/bash
#PBS -l nodes=1:ppn=16
#PBS -l mem=120gb
#PBS -q stsi
#PBS -l walltime=340:00:00
#PBS -j oe


#Example: qsub -v myinput=
#qsub -v myinput=vcf.gz,myoutdir=,mychr= -N 3_6800_JHS_all_chr_sampleID_c1

filename=$(basename $myinput)
inprefix=$(basename $myinput | sed -e 's/\.vcf.gz$//g')
outsubdir=$(basename $myinput | sed -e 's~\.lifted.*~~g')

if [ ! -d $myoutdir/$outsubdir ]; then
    mkdir -p $myoutdir/$outsubdir
fi

cd $myoutdir/$outsubdir


eagle=/gpfs/home/sfchen/bin/Eagle_v2.4.1/eagle
mymap=/mnt/stsi/stsi0/raqueld/1000G/map/genetic_map_GRCh37_merged.txt.gz
myref=/mnt/stsi/stsi0/raqueld/1000G/ALL.chr${mychr}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.bcf
echo "Phasing by 1KG reference, file: $myref"


$eagle --vcfTarget=${myinput} \
  --vcfRef=${myref} \
  --noImpMissing \
  --geneticMapFile=${mymap} \
  --Kpbwt=100000 --numThreads=16 \
  --chrom=${mychr} --allowRefAltSwap \
  --outPrefix=${inprefix}.TGP_phased

tabix -p vcf ${inprefix}.TGP_phased.vcf.gz

echo "Generating intersection between input data and reference panel for ancestry"
myisec=/mnt/stsi/stsi0/raqueld/1000G/ALL.chr${mychr}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.clean.vcf.gz

bcftools isec ${inprefix}.TGP_phased.vcf.gz ${myisec} -p ${inprefix}_tmp -n =2  -w 1,2 --threads 16 -Oz

bcftools merge ${inprefix}_tmp/0000.vcf.gz ${inprefix}_tmp/0001.vcf.gz --threads 16 -Oz -o ${inprefix}.TGP_phased.intersect1KG.vcf.gz
tabix -f -p vcf ${inprefix}.TGP_phased.intersect1KG.vcf.gz


echo "Extracting 23andMe positions only for ancestry analysis, for speeding up ancestry analysis. Original positions will be restored later"
#positions extracted from 190410_snps.23andme.clean.drop_dup.sorted.data
bcftools view -R $PBS_O_WORKDIR/23andme_dropdup.pos ${inprefix}.TGP_phased.intersect1KG.vcf.gz |\
  bcftools norm /dev/stdin -d both |\
  bcftools annotate /dev/stdin -x 'FORMAT' |\
  bcftools annotate /dev/stdin --remove 'INFO' -Oz -o ${inprefix}.TGP_phased.intersect1KG.23andMe_pos.vcf.gz
tabix -p vcf ${inprefix}.TGP_phased.intersect1KG.23andMe_pos.vcf.gz

# plink2 --vcf ${inprefix}.chr$1.23andMe_pos.vcf.gz --indep-pairwise 100 10 0.05 --out $inprefix.chr$1 # produces <name.prune.in> and <name.prune.out>