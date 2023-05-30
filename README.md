# NCBI Gene RDF

## Original data

NCBI Gene

* Data provider
  * National Center for Biotechnology Information
* License
  * https://www.ncbi.nlm.nih.gov/home/about/policies/
* Download
  * ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
  * ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz

## Created RDF

gene_info
```
./bin/ncbigene_rdf.pl original_data/Homo_sapiens.gene_info.2022-05-24 > created_rdf/Homo_sapiens.gene_info.2022-05-24.ttl
```
