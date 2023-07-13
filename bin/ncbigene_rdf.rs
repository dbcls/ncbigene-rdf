use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write, BufWriter};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <input_file>", args[0]);
        return Ok(());
    }
    let input_file = &args[1];

    let file = File::open(input_file)?;
    let reader = BufReader::new(file);

    let stdout = io::stdout();
    let mut handle = BufWriter::new(stdout.lock());

    writeln!(handle, "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .")?;
    writeln!(handle, "@prefix dct: <http://purl.org/dc/terms/> .")?;
    writeln!(handle, "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .")?;
    writeln!(handle, "@prefix ncbigene: <http://identifiers.org/ncbigene/> .")?;
    writeln!(handle, "@prefix taxid: <http://identifiers.org/taxonomy/> .")?;
    writeln!(handle, "@prefix hgnc: <http://identifiers.org/hgnc/> .")?;
    writeln!(handle, "@prefix mim: <http://identifiers.org/mim/> .")?;
    writeln!(handle, "@prefix mirbase: <http://identifiers.org/mirbase/> .")?;
    writeln!(handle, "@prefix ensembl: <http://identifiers.org/ensembl/> .")?;
    writeln!(handle, "@prefix insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/> .")?;
    writeln!(handle, "@prefix : <https://dbcls.github.io/ncbigene-rdf/ontology.ttl#> .")?;

    for line in reader.lines() {
        let line = line?;
        if line.starts_with('#') {
            continue;
        }

        let fields: Vec<&str> = line.split('\t').collect();

        writeln!(handle)?;
        writeln!(handle, "ncbigene:{} a insdc:Gene ;", fields[1])?;
        writeln!(handle, "    dct:identifier {} ;", fields[1])?;
        writeln!(handle, "    rdfs:label {} ;", quote_str(fields[2]))?;
        if fields[10] != "-" {
            writeln!(handle, "    insdc:standard_name {} ;", quote_str(fields[10]))?;
        }
        if fields[3] != "-" {
            writeln!(handle, "    insdc:locus_tag {} ;", quote_str(fields[3]))?;
        }
        if fields[4] != "-" {
            writeln!(handle, "    insdc:gene_synonym {} ;", format_str_array(fields[4]))?;
        }
        if fields[8] != "-" {
            writeln!(handle, "    dct:description {} ;", quote_str(fields[8]))?;
        }
        if fields[13] != "-" {
            let others = format_str_array_exclude(fields[13], fields[8]);
            if others != "" {
                writeln!(handle, "    dct:alternative {} ;", others)?;
            }
        }
        if fields[5] != "-" {
            let link = format_link(fields[5])?;
            if let Some(link) = link {
                writeln!(handle, "    insdc:dblink {} ;", link)?;
            }
        }
        writeln!(handle, "    :typeOfGene \"{}\" ;", fields[9])?;
        if fields[12] == "O" {
            writeln!(handle, "    :nomenclatureStatus \"official\" ;")?;
        } else if fields[12] == "I" {
            writeln!(handle, "    :nomenclatureStatus \"interim\" ;")?;
        }
        if fields[11] != "-" {
            writeln!(handle, "    :fullName \"{}\" ;", fields[11])?;
        }
        if fields[5] != "-" {
            let db_xref = filter_str(fields[5])?;
            if let Some(db_xref) = db_xref {
                writeln!(handle, "    insdc:db_xref {} ;", db_xref)?;
            }
        }
        if fields[15] != "-" {
            writeln!(handle, "    :featureType {} ;", format_str_array(fields[15]))?;
        }
        writeln!(handle, "    :taxid taxid:{} ;", fields[0])?;
        if fields[6] != "-" {
            writeln!(handle, "    insdc:chromosome \"{}\" ;", fields[6])?;
        }
        if fields[7] != "-" {
            writeln!(handle, "    insdc:map \"{}\" ;", fields[7])?;
        }
        writeln!(handle, "    dct:modified \"{}\"^^xsd:date .", format_date(fields[14]))?;
    }
    Ok(())
}

fn quote_str(s: &str) -> String {
    let mut s: String = s.to_string();
    if s.contains('\\') {
        s = s.replace("\\", "\\\\");
    }

    if s.contains('"') && s.contains('\'') && !s.contains("\"\"\"") {
        format!("\"\"\"{}\"\"\"", s)
    } else if !s.contains('"') {
        format!("\"{}\"", s)
    } else if !s.contains('\'') {
        format!("'{}'", s)
    } else {
        s
    }
}

fn format_date(date: &str) -> String {
    if date.len() == 8 {
        format!("{}-{}-{}", &date[..4], &date[4..6], &date[6..8])
    } else {
        String::new()
    }
}

fn format_str_array(str: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let str_arr: Vec<String> = arr.iter().map(|a| format!("{}", quote_str(a))).collect();
    str_arr.join(" ,\n        ")
}

fn format_str_array_exclude(str: &str, exclude: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let mut out: Vec<String> = Vec::new();
    for a in arr {
        if a == exclude {
            continue;
        }
        out.push(format!("\"{}\"", a));
    }
    out.join(" ,\n        ")
}

fn format_link(str: &str) -> Result<Option<String>, io::Error> {
    let arr: Vec<&str> = str.split('|').collect();
    let mut link = Vec::new();
    for a in arr {
        if let Some(mim) = a.strip_prefix("MIM:") {
            link.push(format!("mim:{}", mim));
        } else if let Some(hgnc) = a.strip_prefix("HGNC:HGNC:") {
            link.push(format!("hgnc:{}", hgnc));
        } else if let Some(ensembl) = a.strip_prefix("Ensembl:") {
            link.push(format!("ensembl:{}", ensembl));
        } else if let Some(mirbase) = a.strip_prefix("miRBase:") {
            link.push(format!("mirbase:{}", mirbase));
        }
    }
    if !link.is_empty() {
        let formatted_link = link.join(" ,\n        ");
        Ok(Some(formatted_link))
    } else {
        Ok(None)
    }
}

fn filter_str(str: &str) -> Result<Option<String>, io::Error> {
    let arr: Vec<&str> = str.split('|').collect();
    let mut link = Vec::new();
    for a in arr {
        if let Some(mim) = a.strip_prefix("MIM:") {
        } else if let Some(hgnc) = a.strip_prefix("HGNC:HGNC:") {
        } else if let Some(ensembl) = a.strip_prefix("Ensembl:") {
        } else if let Some(mirbase) = a.strip_prefix("miRBase:") {
        } else {
            link.push(quote_str(a));
        }
    }
    if !link.is_empty() {
        let formatted_link = link.join(" ,\n        ");
        Ok(Some(formatted_link))
    } else {
        Ok(None)
    }
}
