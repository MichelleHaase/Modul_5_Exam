nextflow.enable.dsl = 2

params.store = "${launchDir}/stored_downloads"
params.accession = "M21012"

process download_Reference
{
	storeDir params.store
	output:
		path "${params.accession}.fasta"
	"""
	wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O ${params.accession}.fasta
	"""
}

workflow
{
	infile_channel = download_Reference()
}