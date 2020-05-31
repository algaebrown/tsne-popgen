#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l mem=30gb
#PBS -q stsi
#PBS -l walltime=340:00:00
#PBS -j oe

# Example: qsub -v pair=[pairwise/pairphase],rcutoff=[0.01/0.02/0.05/0.1],file=[1/2/3/4] -N [pair]_[rcutoff]_[file]

main=/mnt/stsi/stsi0/sfchen/CSE284
cd ${main}

file1=ALL.TGP_HGDP.GRCh37.bi.sorted.fixref.phased.isec.geno.200-100-${rcutoff}_${pair}.txt
file2=ALL.TGP_HGDP.GRCh37.bi.sorted.fixref.phased.isec.geno.5000-1000-${rcutoff}_${pair}.txt
file3=ALL.TGP_HGDP.GRCh37.bi.sorted.fixref.phased.isec.geno.23andMe.200-100-${rcutoff}_${pair}.txt
file4=ALL.TGP_HGDP.GRCh37.bi.sorted.fixref.phased.isec.geno.23andMe.5000-1000-${rcutoff}_${pair}.txt

if [[ ${file} == '1' ]]; then
    for chrom in {1..22}; do 
        subdir=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi
        tgp_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.geno.vcf.gz
        echo ${main}/${subdir}/${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz
    done > ${main}/${file1}
    bcftools concat -f ${main}/${file1} | bcftools reheader /dev/stdin -s ${main}/hgdp.rename.txt -o ${main}/${file1/.txt/.vcf}
    bgzip -c ${main}/${file1/.txt/.vcf} -@ 16 > ${main}/${file1/.txt/.vcf}.gz
    tabix -p vcf ${main}/${file1/.txt/.vcf.gz}
    
elif [[ ${file} == '2' ]]; then
    for chrom in {1..22}; do 
        subdir=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi
        tgp_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.geno.vcf.gz
        echo ${main}/${subdir}/${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz
    done > ${main}/${file2}
    bcftools concat -f ${main}/${file2} | bcftools reheader /dev/stdin -s ${main}/hgdp.rename.txt -o ${main}/${file2/.txt/.vcf}
    bgzip -c ${main}/${file2/.txt/.vcf} -@ 16 > ${main}/${file2/.txt/.vcf}.gz
    tabix -p vcf ${main}/${file2/.txt/.vcf.gz}
    
elif [[ ${file} == '3' ]]; then
    for chrom in {1..22}; do 
        subdir=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi
        tgp_ttm_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.23andMe_pos.geno.vcf.gz
        echo ${main}/${subdir}/${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz
    done > ${main}/${file3}
    bcftools concat -f ${main}/${file3} | bcftools reheader /dev/stdin -s ${main}/hgdp.rename.txt -o ${main}/${file3/.txt/.vcf}
    bgzip -c ${main}/${file3/.txt/.vcf} -@ 16 > ${main}/${file3/.txt/.vcf}.gz
    tabix -p vcf ${main}/${file3/.txt/.vcf.gz}
    
else
    for chrom in {1..22}; do 
        subdir=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi
        tgp_ttm_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.23andMe_pos.geno.vcf.gz
        echo ${main}/${subdir}/${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz
    done > ${main}/${file4}
    bcftools concat -f ${main}/${file4} | bcftools reheader /dev/stdin -s ${main}/hgdp.rename.txt -o ${main}/${file4/.txt/.vcf}
    bgzip -c ${main}/${file4/.txt/.vcf} -@ 16 > ${main}/${file4/.txt/.vcf}.gz
    tabix -p vcf ${main}/${file4/.txt/.vcf.gz}
fi
    
    






