#!/usr/bin/perl -w
use strict;
use Cwd qw/abs_path/;
use File::Basename qw/basename dirname/;
use FindBin qw/$RealScript $RealBin/;
use Getopt::Long;

die "Usage:\tperl $0 <SMAP OUT> <Sample Name> <Sample Type> <Library> <Lane> <bamdst_bed> <perl bin>\n"if(@ARGV!=7);

###############################

my $smap_out=shift;
my $sample_name=shift;
my $sample_type=shift;
my $library=shift;
my $fowcell=shift;
my $bamdst_bed=shift;
my $Bin=shift;
my $bamdst_para="--cutoffdepth 350 --maxdepth 1000 -q 1";
my $fastqc="$Bin/FastQC/fastqc";
my $samtools="$Bin/samtools";
my $bamst="$Bin/bamdst";

my $out="$smap_out/report/$sample_name/$sample_type";
my $out_l="$smap_out/report/$sample_name/$sample_type/$library";
my $out_f="$smap_out/report/$sample_name/$sample_type/$library/$fowcell";
`mkdir -p $out` unless(-d $out);
`mkdir -p $out_l` unless(-d $out_l);
`mkdir -p $out_f` unless(-d $out_f);

system("$fastqc -o $out_f $smap_out/$sample_name/$sample_type/$library/$fowcell/t_clean1.fq $smap_out/$sample_name/$sample_type/$library/$fowcell/a_clean2.fq");
system("unzip $out_f/t_clean1.fq_fastqc.zip -d $out_f");
system("unzip $out_f/a_clean2.fq_fastqc.zip -d $out_f");

system("$samtools flagstat $smap_out/$sample_name/$sample_type/$library/$fowcell/outfile.bam >$out_f/outfile.bam.stat");

my $total_bamstat="$out/BSMAP.sort.bam.stat";
if(!($total_bamstat && abs_path($total_bamstat))){
	system("$samtools flagstat $smap_out/$sample_name/$sample_type/ASM/BSMAP.sort.bam >$total_bamstat");
}

my $out_co="$out/coverage";
if(!($out_co && abs_path($out_co))){
	`mkdir -p $out_co` unless(-d $out_co);
	system("$bamst $bamdst_para -p $bamdst_bed -o $out_co $smap_out/$sample_name/$sample_type/ASM/BSMAP.sort.bam");
	system("$Bin/bamdstPlot.pl -i $out_co/depth_distribution.plot -c $out_co/coverage.report -o  $out_co");
}

##---------------------------Perl End---------------------------##
