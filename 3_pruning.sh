#!/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -l mem=60gb
#PBS -q stsi
#PBS -l walltime=340:00:00
#PBS -j oe

# Example: qsub -v chrom=[chr],pair=[pairwise/pairphase],rcutoff=[0.01/0.02/0.05/0.1/0.2/0.5]

main=/mnt/stsi/stsi0/sfchen/CSE284

# for i in {1..22}; do
#     for p in pairwise pairphase; do
        subdir=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi

        cd ${main}/${subdir}

        tgp=intersect1KG
        tgp_ttm=intersect1KG.23andMe

        tgp_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.vcf.gz
        tgp_ttm_fp=hgdp_wgs.20190516.statphase.autosomes.chr${chrom}.bi.lifted_GRCh38_to_GRCh37.sorted.fixref.bi.TGP_phased.intersect1KG.23andMe_pos.vcf.gz

        # bcftools +prune ${tgp_fp} -l1 -e'F_MISSING>0' -Oz -o ${tgp_fp/.vcf.gz/.geno.vcf.gz}
        tgp_fp=${tgp_fp/.vcf.gz/.geno.vcf.gz}
        # tabix -p vcf ${tgp_fp}
        
        # bcftools +prune ${tgp_ttm_fp} -l1 -e'F_MISSING>0' -Oz -o ${tgp_ttm_fp/.vcf.gz/.geno.vcf.gz}
        tgp_ttm_fp=${tgp_ttm_fp/.vcf.gz/.geno.vcf.gz}
        # tabix -p vcf ${tgp_ttm_fp}
        

        # produces <name.prune.in> and <name.prune.out>
        plink --vcf ${tgp_fp} --indep-${pair} 200 100 ${rcutoff} --out ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}
        vcftools --gzvcf ${tgp_fp} --snps ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.prune.in --recode --out ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}
        bgzip -c ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf > ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz
        tabix -p vcf ${tgp_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz

        plink --vcf ${tgp_fp} --indep-${pair} 5000 1000 ${rcutoff} --out ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}
        vcftools --gzvcf ${tgp_fp} --snps ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.prune.in --recode --out ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}
        bgzip -c ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf > ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz
        tabix -p vcf ${tgp_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz

        plink --vcf ${tgp_ttm_fp} --indep-${pair} 200 100 ${rcutoff} --out ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}
        vcftools --gzvcf ${tgp_ttm_fp} --snps ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.prune.in --recode --out ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}
        bgzip -c ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf > ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz
        tabix -p vcf ${tgp_ttm_fp/.vcf.gz}_200-100-${rcutoff}_${pair}.recode.vcf.gz
        
        plink --vcf ${tgp_ttm_fp} --indep-${pair} 5000 1000 ${rcutoff} --out ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}
        vcftools --gzvcf ${tgp_ttm_fp} --snps ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.prune.in --recode --out ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}
        bgzip -c ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf > ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz
        tabix -p vcf ${tgp_ttm_fp/.vcf.gz}_5000-1000-${rcutoff}_${pair}.recode.vcf.gz
#     done
# done
