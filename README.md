# NCBI Gene RDF

## Original data
* Data provider
  * National Center for Biotechnology Information
* License
  * https://www.ncbi.nlm.nih.gov/home/about/policies/
* Download
  * ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
  * ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz

## Created RDF

gene2go (simple version):
```
$ gunzip gene2go.gz
$ cat gene2go | grep -P '^9606' | ./gene2go.pl > gene2go.human.ttl
```

```
@prefix : <http://purl.org/net/orthordf/hOP/ontology#> .
@prefix ncbigene: <http://identifiers.org/ncbigene/> .
@prefix obo: <http://purl.obolibrary.org/obo/> .

ncbigene:1 :hasGO obo:GO_0005576, obo:GO_0005615, obo:GO_0031093, obo:GO_0034774, obo:GO_0062023, obo:GO_0070062, obo:GO_0072562, obo:GO_1904813 .

```

gene2go (full version):
```
$ gunzip gene2go.gz
$ ./gene2go.pl gene2go > gene2go.ttl
```

Part of Turtle file:
```
@prefix ncbigene: <http://identifiers.org/ncbigene/> .
@prefix obo: <http://purl.obolibrary.org/obo/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix pmid: <http://identifiers.org/pubmed/> .
@prefix taxid: <http://identifiers.org/taxonomy/> .
@prefix : <http://purl.org/orthordf/ontology#> .

...

ncbigene:10 :hasGOAnnotation
    [
        :hasGO obo:GO_0004060 ;
        :category :Function ;
        :evidence :IBA ;
        :qualifier :enables ;
        rdfs:label "arylamine N-acetyltransferase activity" ;
        dct:references pmid:21873635
    ],
    [
        :hasGO obo:GO_0004060 ;
        :category :Function ;
        :evidence :TAS ;
        :qualifier :enables ;
        rdfs:label "arylamine N-acetyltransferase activity" ;
        dct:references :NA
    ],
    [
        :hasGO obo:GO_0005515 ;
        :category :Function ;
        :evidence :IPI ;
        :qualifier :enables ;
        rdfs:label "protein binding" ;
        dct:references pmid:25640309, pmid:32296183
    ],
    [
        :hasGO obo:GO_0005829 ;
        :category :Component ;
        :evidence :TAS ;
        :qualifier :located_in ;
        rdfs:label "cytosol" ;
        dct:references :NA
    ],
    [
        :hasGO obo:GO_0006805 ;
        :category :Process ;
        :evidence :TAS ;
        :qualifier :involved_in ;
        rdfs:label "xenobiotic metabolic process" ;
        dct:references :NA
    ];
    :gene2go obo:GO_0004060, obo:GO_0005515, obo:GO_0005829, obo:GO_0006805 ;
    :taxid taxid:9606 .

ncbigene:12 :hasGOAnnotation
    [
        :hasGO obo:GO_0003677 ;
        :category :Function ;
        :evidence :TAS ;
        :qualifier :enables ;
        rdfs:label "DNA binding" ;
        dct:references pmid:14668352
    ],
    [
...
    [
        :hasGO obo:GO_0045540 ;
        :category :Process ;
        :evidence :IDA ;
        :qualifierNOT :involved_in ;
        rdfs:label "regulation of cholesterol biosynthetic process" ;
        dct:references pmid:21810484
    ],
...
```
