# NCBI Gene RDF

## Original data

NCBI Gene

* Data provider
  * National Center for Biotechnology Information
* License
  * https://www.ncbi.nlm.nih.gov/home/about/policies/
* Download
  * ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz

## Created RDF

```
$ ./bin/ncbigene_rdf.pl gene_info
```

Creator
* Hirokazu Chiba

RDF config
* https://github.com/dbcls/rdf-config/tree/master/config/ncbigene

Schema
* https://raw.githubusercontent.com/dbcls/rdf-config/master/config/ncbigene/schema.svg

Metadata
* https://github.com/dbcls/rdf-config/blob/master/config/ncbigene/metadata.yaml
* https://github.com/dbcls/rdf-config/blob/master/config/ncbigene/metadata_ja.yaml

SPARQL
* [gene_info.rq](https://github.com/dbcls/ncbigene-rdf/blob/main/sparql/gene_info.rq)
* [gene_types.rq](https://github.com/dbcls/ncbigene-rdf/blob/main/sparql/gene_types.rq)

## Ontology

Ontology for NCBI Gene
* https://dbcls.github.io/ncbigene-rdf/ontology.ttl (GitHub Pages)
