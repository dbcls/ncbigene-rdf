use std::env;
use std::fs::File;
use std::io::{self, BufRead, Write};

fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <input_file>", args[0]);
        return Ok(());
    }
    let input_file = &args[1];
    let file = File::open(input_file)?;

    let mut writer = io::BufWriter::new(io::stdout());

    writeln!(writer, "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .")?;
    writeln!(writer, "@prefix dct: <http://purl.org/dc/terms/> .")?;
    writeln!(writer, "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .")?;
    writeln!(writer, "@prefix ncbigene: <http://identifiers.org/ncbigene/> .")?;
    writeln!(writer, "@prefix taxid: <http://identifiers.org/taxonomy/> .")?;
    writeln!(writer, "@prefix hgnc: <http://identifiers.org/hgnc/> .")?;
    writeln!(writer, "@prefix mim: <http://identifiers.org/mim/> .")?;
    writeln!(writer, "@prefix mirbase: <http://identifiers.org/mirbase/> .")?;
    writeln!(writer, "@prefix ensembl: <http://identifiers.org/ensembl/> .")?;
    writeln!(writer, "@prefix insdc: <http://ddbj.nig.ac.jp/ontologies/nucleotide/> .")?;
    writeln!(writer, "@prefix : <https://dbcls.github.io/ncbigene-rdf/ontology.ttl#> .")?;

    let reader = io::BufReader::new(file);
    for line in reader.lines() {
        let line = line?;
        if line.starts_with('#') {
            continue;
        }

        let fields: Vec<&str> = line.split('\t').collect();

        writeln!(writer, "")?;
        writeln!(writer, "ncbigene:{} a insdc:Gene ;", fields[1])?;
        writeln!(writer, "    dct:identifier {} ;", fields[1])?;
        writeln!(writer, "    rdfs:label {} ;", quote_str(fields[2]))?;
        if fields[10] != "-" {
            writeln!(writer, "    insdc:standard_name {} ;", quote_str(fields[10]))?;
        }
        if fields[3] != "-" {
            writeln!(writer, "    insdc:locus_tag {} ;", quote_str(fields[3]))?;
        }
        if fields[4] != "-" {
            writeln!(writer, "    insdc:gene_synonym {} ;", format_str_array(fields[4]))?;
        }
        if fields[8] != "-" {
            writeln!(writer, "    dct:description {} ;", quote_str(fields[8]))?;
        }
        if fields[13] != "-" {
            let others = format_str_array_exclude(fields[13], fields[8]);
            if others != "" {
                writeln!(writer, "    dct:alternative {} ;", others)?;
            }
        }
        if fields[5] != "-" {
            let link = format_link(fields[5]);
            if link != "" {
                writeln!(writer, "    insdc:dblink {} ;", link)?;
            }
        }
        writeln!(writer, "    :typeOfGene \"{}\" ;", fields[9])?;
        if fields[12] == "O" {
            writeln!(writer, "    :nomenclatureStatus \"official\" ;")?;
        } else if fields[12] == "I" {
            writeln!(writer, "    :nomenclatureStatus \"interim\" ;")?;
        }
        if fields[11] != "-" {
            writeln!(writer, "    :fullName \"{}\" ;", fields[11])?;
        }
        if fields[5] != "-" {
            let db_xref = filter_str(fields[5]);
            if db_xref != "" {
                writeln!(writer, "    insdc:db_xref {} ;", db_xref)?;
            }
        }
        if fields[15] != "-" {
            writeln!(writer, "    :featureType {} ;", format_str_array(fields[15]))?;
        }
        writeln!(writer, "    :taxid taxid:{} ;", fields[0])?;
        if fields[6] != "-" {
            writeln!(writer, "    insdc:chromosome \"{}\" ;", fields[6])?;
        }
        if fields[7] != "-" {
            writeln!(writer, "    insdc:map \"{}\" ;", fields[7])?;
        }
        writeln!(writer, "    dct:modified \"{}\"^^xsd:date .", format_date(fields[14]))?;
    }
    Ok(())
}

fn quote_str(s: &str) -> String {
    let mut r = String::from(s);
    if r.contains('\\') {
        r = r.replace("\\", "\\\\");
    }

    if r.contains('"') && r.contains('\'') && !r.contains("\"\"\"") {
        format!("\"\"\"{}\"\"\"", r)
    } else if !r.contains('"') {
        format!("\"{}\"", r)
    } else if !r.contains('\'') {
        format!("'{}'", r)
    } else {
        r
    }
}

fn format_str_array(str: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let str_arr: Vec<String> = arr.iter().map(|a| quote_str(a)).collect();
    str_arr.join(" ,\n        ")
}

fn format_str_array_exclude(str: &str, exclude: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let mut out: Vec<String> = Vec::new();
    for a in arr {
        if a == exclude {
            continue;
        }
        out.push(quote_str(a));
    }
    out.join(" ,\n        ")
}

fn format_link(str: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let mut link: Vec<String> = Vec::new();
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
    link.join(" ,\n        ")
}

fn filter_str(str: &str) -> String {
    let arr: Vec<&str> = str.split('|').collect();
    let mut link: Vec<String> = Vec::new();
    for a in arr {
        if a.starts_with("MIM:") {
        } else if a.starts_with("HGNC:HGNC:") {
        } else if a.starts_with("Ensembl:") {
        } else if a.starts_with("miRBase:") {
        } else {
            link.push(quote_str(a));
        }
    }
    link.join(" ,\n        ")
}

fn format_date(date: &str) -> String {
    if date.len() == 8 {
        format!("{}-{}-{}", &date[..4], &date[4..6], &date[6..8])
    } else {
        String::new()
    }
}
