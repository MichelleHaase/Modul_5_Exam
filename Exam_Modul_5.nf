nextflow.enable.dsl = 2

params.store = "${launchDir}/stored_downloads"
params.accession = "M21012"
params.testfolder ="${launchDir}/Testdata_Exam_5/"
params.out = "${launchDir}"

process download_Reference
{
	storeDir params.store
	output:
		path "${params.accession}.fasta"
	"""
	wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O ${params.accession}.fasta
	"""
}

process combine_testdata
{
	publishDir params.out, mode: "copy", overwrite: true
	input:
		path "*.fasta"
	output:
		path "testdata_combined.fasta"
	"""
	cat *.fasta > testdata_combined.fasta
	"""
}

process combine_Reference_testdata
{
	publishDir params.out, mode: "copy", overwrite: true
	input:
		path "*.fasta"
	output:
		path "${params.accession}_testdata_combined.fasta"
	"""
	cat *.fasta > ${params.accession}_testdata_combined.fasta
	"""
}
workflow
{
	test_result_channel = channel.fromPath("${params.testfolder}*.fasta").flatten()
	reference_channel = download_Reference()
	combine_channel = reference_channel.concat(test_result_channel).collect()| combine_Reference_testdata
}
