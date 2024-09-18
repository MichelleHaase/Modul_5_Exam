nextflow.enable.dsl = 2

params.store = "${launchDir}/stored_downloads"
params.accession = "M21012"
params.testfolder ="${launchDir}/Testdata_Exam_5/"
params.out = "${launchDir}/results"

process download_Reference
{
	storeDir params.store
	output:
		path "${params.accession}.fasta"
	"""
	wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O ${params.accession}.fasta
	"""
}

process combine_Reference_testdata
{
	storeDir params.store
	input:
		path "*.fasta"
	output:
		path "${params.accession}_testdata_combined.fasta"
	"""
	cat *.fasta > ${params.accession}_testdata_combined.fasta
	"""
}

process mafft
{
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
	input:
		path infile
	output:
		path "${params.accession}_maffted.fasta"
	"""
	mafft $infile > ${params.accession}_maffted.fasta
	"""
}

process trimal
{
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h4ac6f70_1"
	input:
		path infile
	output:
		path "${infile}*"
	"""
	trimal -in $infile -out ${infile}.trimal.fasta -htmlout ${infile}_report.html -automated1
	"""
}
workflow
{
	test_result_channel = channel.fromPath("${params.testfolder}*.fasta").flatten()
	reference_channel = download_Reference()
	combine_channel = reference_channel.concat(test_result_channel).collect()| combine_Reference_testdata | mafft | trimal
}
