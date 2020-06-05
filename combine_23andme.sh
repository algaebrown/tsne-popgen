# create a position file from reference population
bcftools query -f '%CHROM\t%POS\n' $1 > reference.pos

# filter SNP by mask
bcftools view $2 -R reference.pos -Oz -o masked_$2
tabix -p vcf masked_$2

# merge reference population with masked 23andMe data
bcftools merge $1 masked_$2 -Oz -o output.vcf.gz