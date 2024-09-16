nextflow.enable.dsl = 2

params.store = "${launchDir}/stored_downloads"
params.accession = "M21012.fasta"

process download_Reference
{
	storeDir params.store
	output:
		path "${params.accession}"
	"""
	wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text" -O ${params.accession}
	"""
}

workflow
{
	infile_channel = download_Reference()
}