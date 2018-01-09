#!/usr/bin/perl -w
use strict;
use File::Basename qw/basename dirname/;
use Cwd qw/abs_path/;
use FindBin qw/$RealScript $RealBin/;
use Getopt::Long;

my ($CONFIG,$RES_PATH,$BIN,$BED_DIR,$OUT_DIR,$CUTLEN,$HELP);

GetOptions(
        "-c:s"    => \$CONFIG,
        "-p:s"    => \$RES_PATH,
        "-b:s"    => \$BIN,
		"-d:s"    => \$BED_DIR,
		"-l:s"	  => \$CUTLEN,	
        "-h|help" => \$HELP
);

if(!($HELP)) {
	if(!($CONFIG && abs_path($CONFIG))) {
                print "Invalid configure file!\n";
        }

        if(!($RES_PATH)) {
                print "Invalid output path!\n";
        }
}

die "Usage:
\tperl $0 [Options]
Version:
\tV1.0 at 2017-12-12
Options:
\t-c   [s]  Config File of AA_SMAP pipeline. <required>
\t-p   [s]  Directory which will store all SMAP results. <required>
\t-b   [s]  Bin Directory. <required>
\t-d   [s]  Bedfile Directory. <required>
\t-l   [s]  Count cut off length. <required> 
\t-h        Display this help info.
\n" if($HELP || !($CONFIG && &abs_path($CONFIG)) || !($RES_PATH));

my $con=$CONFIG;
my $respath=$RES_PATH;
my $beddir=$BED_DIR;
my $cutlen=$CUTLEN;
my $Bin=$BIN;
die "Error! Invalid sample path of $respath\n" unless(-e $respath);

my $report="$respath/report";
my $shell_path="$respath/report/shell";
`mkdir -p $report` unless(-d $report);
`mkdir -p $shell_path` unless(-d $shell_path);

open CON, "$con" or die "Unable to open configure file!\n";
my ($ref,$region,$target);
my %hash;
while(<CON>){
	chomp;
	next if(/\#/);

	if(/^Reference/){
		my @sp=split /\=/;
		$sp[-1]=~s/^\s+//;
		$ref=$sp[-1];
	}

	if(/^Region/){
		my @sp=split /\=/;
		$sp[-1]=~s/^\s+//;
		$region=$sp[-1];
	}

	if(/^Target/){
		my @sp=split /\=/;
		$sp[-1]=~s/^\s+//;
		$target=$sp[-1];
	}

	if(/^Sample/){
		my @sp=split /\=/;
		$sp[1]=~s/^\s+//;
		my @saminfo=split /\s+/,$sp[1];

		my $sample_path="$respath/report/$saminfo[0]";
		my $type_path="$respath/report/$saminfo[0]/$saminfo[1]";
		`mkdir -p $sample_path` unless(-d $sample_path);
		`mkdir -p $type_path` unless(-d $type_path);

		if(exists $hash{$saminfo[0]}{$saminfo[1]}){
			my $shell="$shell_path/work.$saminfo[0]_$saminfo[1].sh";
			open SH, ">>$shell" or die "Cant open $shell";

			print SH "######### Different Lane Fastq QC #########\n";
			print SH "perl $Bin/fq_qc.pl $respath $saminfo[0] $saminfo[1] $saminfo[3] $saminfo[4] $region $Bin\n";			
		}else{
			my $shell="$shell_path/work.$saminfo[0]_$saminfo[1].sh";
			open SH, ">$shell" or die "Cant open $shell";

			print SH "######### Fastq QC #########\n";
			print SH "perl $Bin/fq_qc.pl $respath $saminfo[0] $saminfo[1] $saminfo[3] $saminfo[4] $region $Bin\n";
			print SH "######## Methrate Count ########\n";
			print SH "perl $Bin/count_methrate.pl $respath $saminfo[0] $saminfo[1] $ref.len $beddir $target\n";
			print SH "######## 9bp Count #######\n";
			print SH "perl $Bin/count.9bp.3and4.frequence.pl $respath $saminfo[0] $saminfo[1] $ref\n";
			print SH "######## window cut methrate count ########\n";
			print SH "perl $Bin/make_table.pl $cutlen $ref.len $type_path/meth.cg.rate $type_path/meth.chg.rate $type_path/meth.chh.rate $type_path/Distribution.txt\n";

			print SH "######## Element methrate count ########\n";
			print SH "python $Bin/element.zone.py $type_path/meth.cg.rate $beddir/CDS.bed $type_path/CDS.50zone.txt\n";
			print SH "python $Bin/element.zone.py $type_path/meth.cg.rate $beddir/Upstream2k.bed $type_path/Upstream2k.50zone.txt\n";
			print SH "python $Bin/element.zone.py $type_path/meth.cg.rate $beddir/Downstream2k.bed $type_path/Downstream2k.50zone.txt\n";
			print SH "python $Bin/element.zone.py $type_path/meth.cg.rate $beddir/Intron.bed $type_path/Intron.50zone.txt\n";
			print SH "perl $Bin/add.methzone.pl $type_path/CDS.50zone.txt $type_path/Upstream2k.50zone.txt $type_path/Downstream2k.50zone.txt $type_path/Intron.50zone.txt $type_path/element.50zone.txt\n";

			my $dmr="$respath/$saminfo[0]/$saminfo[1]/DMR/dmr.out";
			if(-e $dmr){
				print SH "####### DMR Count ########\n";
				print SH "perl $Bin/getgene.pl $respath/$saminfo[0]/$saminfo[1]/DMR/dmr.out.Upstream2k $type_path/dmr.out.gene.uniq $type_path/dmr.out.gene\n";
				print SH "perl $Bin/dmr.match.bed.pl $respath $saminfo[0] $saminfo[1] $beddir $type_path\n";
			}
			$hash{$saminfo[0]}{$saminfo[1]}='miao';
		}
	}	
}

print "DONE!";
close CON;
close SH;
##---------------------------Perl End---------------------------##
