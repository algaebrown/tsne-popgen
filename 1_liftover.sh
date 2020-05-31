#!/bin/bash
#PBS -l nodes=1:ppn=16
#PBS -l mem=120gb
#PBS -q stsi
#PBS -l walltime=340:00:00
#PBS -j oe

# qsub -v myinput=

echo "Running on node:"
hostname

module load plink2
module load ucsc_tools/373
# module load vcftools
module load samtools/1.9

cd $PBS_O_WORKDIR

filename=$(basename $myinput)
inprefix=${filename/.vcf.gz/}
name=${inprefix}

main=/mnt/stsi/stsi0/sfchen/dbGaP/Genotype_Imputation_Pipeline
lift=${main}/required_tools/lift/LiftMap.py
cpath=${main}/required_tools/chainfiles
cfilename=GRCh38_to_GRCh37.chain
liftname=$(echo $cfilename |  sed -e 's/\.chain.*//g')

nchains=$(echo $cfilename | tr ' ' '\n' | wc -l | awk '{print $1}')
checknone=$(grep "Use chain file" $buildcheck | grep "none" | wc -l)
# /mnt/stsi/stsi0/sfchen/dbGaP/Genotype_Imputation_Pipeline/required_tools/chainfiles/hg38_to_GRCh37.chain


# Raw input merged (chr1-22) or split chrom
# View –m 2 –M2 –v snps (multi-allelic, indel; but duplicates keep)
# (sorting)
# Recode to ped/map
# LiftOver
# (chr1->chr22) ; (strand flip)
# (duplicates, A/T + A/T); (new multi, A/T + A/C); (weird pair, A/T + C/T, A/T + C/G) 
# Recode to bed/bim/fam to vcf
# (a1-allele)
# Sorting or Discard (chr1->chr22)
# Fixref (weird pair); (strand flip); (a1-allele) (duplicates) (real multi)
# Norm –m+any | view –m2 –M2 –v snps Merge/Remove duplicates
# GH (randomly ignore duplicates; keep first only)


echo "Remove multi-allelic variants"
bcftools annotate --set-id '%CHROM:%POS:%REF:%ALT' ${myinput} | bcftools view /dev/stdin -M 2 -m 2 -v snps -Oz -o ${name}.bi.vcf.gz --threads 16
tabix -p vcf ${name}.bi.vcf.gz

echo "Converting vcf to ped/map.."
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\n' $name.bi.vcf.gz > $name.bi.pos
plink --vcf $name.bi.vcf.gz --make-bed --a1-allele $name.bi.pos 5 3 --biallelic-only strict --set-missing-var-ids @:#:\$1:\$2 --vcf-half-call missing --double-id --recode ped --out $name.bi

echo "Lifting ped/map using chain file(s): $cfilename..."
$lift -p $name.bi.ped -m $name.bi.map -c $cpath/$cfilename -o $name.bi.lifted_$liftname

echo "Converting lifted output $name.lifted_$liftname to bed/bim/fam..."
plink --file $name.bi.lifted_$liftname --double-id --set-missing-var-ids @:#:\$1:\$2 --allow-extra-chr --make-bed --out ${name}.bi.lifted_${liftname}.tmp

echo "Recovering A1..."
less ${name}.bi.lifted_${liftname}.tmp.bim | tr ':' '\t' | awk '{if($4==$9){print $1"\t"$2":"$3":"$4":"$5"\t"$6"\t"$7"\t"$5"\t"$4}else{print $1"\t"$2":"$3":"$4":"$5"\t"$6"\t"$7"\t"$4"\t"$5}}' > ${name}.bi.lifted_${liftname}.tmp.fixed.bim
cp ${name}.bi.lifted_${liftname}.tmp.fixed.bim ${name}.bi.lifted_${liftname}.tmp.bim

echo "Recoding to vcf..."
plink --bfile $name.bi.lifted_${liftname}.tmp --double-id --set-missing-var-ids @:#:\$1:\$2 --allow-extra-chr --make-bed --recode vcf bgz --a1-allele ${name}.bi.lifted_${liftname}.tmp.bim 5 2 --out ${name}.bi.lifted_${liftname}
tabix -p vcf ${name}.bi.lifted_${liftname}.vcf.gz

echo "Trimming the lifted output"
chrom=$(echo $inprefix | tr '.' '\n' | tr '_' '\n' | grep "chr" | sed 's/chr//g')
bcftools view ${name}.bi.lifted_${liftname}.vcf.gz -r ${chrom} -Oz -o ${name}.bi.lifted_${liftname}.sorted.vcf.gz --threads 16
tabix -p vcf ${name}.bi.lifted_${liftname}.sorted.vcf.gz

echo "Fix flips by reference build..."
ref_path=/mnt/stsi/stsi0/raqueld/1000G
bcftools +fixref ${name}.bi.lifted_${liftname}.sorted.vcf.gz --threads 16 -Oz -o ${name}.bi.lifted_${liftname}.sorted.fixref.vcf.gz -- -f ${ref_path}/human_g1k_v37.fasta -m flip -d

echo "Remove lift-derived multi-allelic variants, again"
bcftools view ${name}.bi.lifted_${liftname}.sorted.fixref.vcf.gz -M 2 -m 2 -v snps | bcftools norm -m+any | bcftools view /dev/stdin -m 2 -M 2 -Oz -o ${name}.bi.lifted_${liftname}.sorted.fixref.bi.vcf.gz
tabix -p vcf ${name}.bi.lifted_${liftname}.sorted.fixref.bi.vcf.gz

for i in ${name}.vcf.gz $name.bi.vcf.gz ${name}.bi.lifted_${liftname}.vcf.gz ${name}.bi.lifted_${liftname}.sorted.vcf.gz ${name}.bi.lifted_${liftname}.sorted.fixref.vcf.gz ${name}.bi.lifted_${liftname}.sorted.fixref.bi.vcf.gz; do
echo ${i}
less ${i} | grep -v "#" | wc -l
done
