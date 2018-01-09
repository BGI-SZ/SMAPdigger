#!/usr/bin/perl -w
use strict;
use File::Basename qw/basename dirname/;
use FindBin qw/$RealScript $RealBin/;
use Getopt::Long;

die "Usage:\tperl $0 <SMAP_path> <sample_name> <sample_type> <fa_len> <bed_dir> <Target>\n"if(@ARGV!=6);

my $SMAP_path=shift;
my $sample_name=shift;
my $sample_type=shift;
my $chrlen=shift;
my $beddir=shift;
my $target=shift;

die "Error! Invalid sample path of $!\n" unless(-e $SMAP_path);
die "Error! Invalid sample path of $SMAP_path\n" unless(-e $SMAP_path);

my $outpath="$SMAP_path/report/$sample_name";
my $outpath2="$outpath/$sample_type";
`mkdir -p $outpath` unless(-d $outpath);
`mkdir -p $outpath2` unless(-d $outpath2);

open CG, "$SMAP_path/$sample_name/$sample_type/ASM/meth.cg" or die $!;
open CHG, "$SMAP_path/$sample_name/$sample_type/ASM/meth.chg" or die $!;
open CHH, "$SMAP_path/$sample_name/$sample_type/ASM/meth.chh" or die $!;	

my ($all_cg, $all_chg, $all_chh);
my ($n,$m,$i,$chr);
my ($o,$p,$q);
my (%cgnum,%chgnum,%chhnum);
my (%cgcount,%chgcount,%chhcount);
		
open METHCG, ">$SMAP_path/report/$sample_name/$sample_type/meth.cg.rate";
print METHCG "#CHROM\tPOS\tCONTEXT\tWatson-METH\tWatson-COVERAGE\tWatson-QUAL\tCrick-METH\tCrick-COVERAGE\tCrick-QUAL\tRATE\n";
while(<CG>){
	chomp;
	next if(/\#/);
	$n++;
	print METHCG "$_\t";
	$_=~s/\./0/g;
	my @cg_meth=split /\s+/,$_;
	my $cg_avg= ($cg_meth[3]+$cg_meth[6])/($cg_meth[4]+$cg_meth[7]);
	if($cg_avg != 0){$o++;}
	print METHCG sprintf "%.8f", "$cg_avg";
	print METHCG "\n";
	$all_cg+=$cg_avg;
	$chr=$cg_meth[0];
	$cgnum{$chr}++;
	$cgcount{$chr}+=$cg_avg;
}
close METHCG;

open METHCHG, ">$SMAP_path/report/$sample_name/$sample_type/meth.chg.rate";
print METHCHG "#CHROM\tPOS\tCONTEXT\tWatson-METH\tWatson-COVERAGE\tWatson-QUAL\tCrick-METH\tCrick-COVERAGE\tCrick-QUAL\tRATE\n";
while(<CHG>){
	chomp;
	next if(/\#/);
	$m++;
	print METHCHG "$_\t";
	$_=~s/\./0/g;
	my @chg_meth=split /\s+/,$_;
	my $chg_avg= ($chg_meth[3]+$chg_meth[6])/($chg_meth[4]+$chg_meth[7]);
	if($chg_avg != 0){$p++;}
	print METHCHG sprintf "%.8f", "$chg_avg";
	print METHCHG "\n";
	$all_chg+=$chg_avg;
	$chr=$chg_meth[0];
	$chgnum{$chr}++;
	$chgcount{$chr}+=$chg_avg;
}
close METHCHG;

open METHCHH, ">$SMAP_path/report/$sample_name/$sample_type/meth.chh.rate";
print METHCHH "#CHROM\tPOS\tCONTEXT\tWatson-METH\tWatson-COVERAGE\tWatson-QUAL\tCrick-METH\tCrick-COVERAGE\tCrick-QUAL\tRATE\n";
while(<CHH>){
	chomp;
	next if(/\#/);
	$i++;
	print METHCHH "$_\t";
	$_=~s/\./0/g;
	my @chh_meth=split /\s+/,$_;
	my $chh_avg= ($chh_meth[3]+$chh_meth[6])/($chh_meth[4]+$chh_meth[7]);
	if($chh_avg != 0){$q++;}
	print METHCHH sprintf "%.8f", "$chh_avg";
	print METHCHH "\n";
	$all_chh+=$chh_avg;
	$chr=$chh_meth[0];
	$chhnum{$chr}++;
	$chhcount{$chr}+=$chh_avg;
}
close METHCHH;

open CHRLEN, "$chrlen" or die $!;
open METH, ">$SMAP_path/report/$sample_name/$sample_type/meth.chr.rate";
print METH "#Average Methylation Level of the Whole Genome\n";
print METH "##$sample_name\t$sample_type\n#Chrosome\tCG(%)\tCHG(%)\tCHH(%)\n";
while(<CHRLEN>){
	chomp;
	my $key=(split /\s+/,$_)[0];
	my $cg_chr=($cgcount{$key}/$cgnum{$key})*100;
	my $chg_chr=($chgcount{$key}/$chgnum{$key})*100;
	my $chh_chr=($chhcount{$key}/$chhnum{$key})*100;
	print METH "$key\t";
	print METH sprintf "%.2f", "$cg_chr";
	print METH "\t";
	print METH sprintf "%.2f","$chg_chr";
	print METH "\t";
	print METH sprintf "%.2f","$chh_chr";
	print METH "\n";
}
my $ch_lev=($all_cg/$n)*100;
my $chg_lev=($all_chg/$m)*100;
my $chh_lev=($all_chh/$i)*100;
print METH "Total\t$ch_lev\t$chg_lev\t$chh_lev\n";
print METH "\n";
close METH;

close CG;
close CHG;
close CHH;

open AELE, ">$SMAP_path/report/$sample_name/$sample_type/region_methlevel.info";
print AELE "#Average methylation level of some elements (%)\n";
my $bed_path=`ls $beddir/*`;
my @link=split /\n/, $bed_path;
my (%element_cg,%element_chg,%element_chh);
my (%ele_num_cg,%ele_num_chg,%ele_num_chh);
foreach(@link){
	open BED, "$_" or die $!;
	$_=~/(.*)\.bed/;
	my $ele_name=(split /\//,$1)[-1];
	open CG, "$SMAP_path/$sample_name/$sample_type/ASM/meth.cg" or die $!;
	<CG>;
	open CHG, "$SMAP_path/$sample_name/$sample_type/ASM/meth.chg" or die $!;
	<CHG>;
	open CHH, "$SMAP_path/$sample_name/$sample_type/ASM/meth.chh"  or die $!;
	<CHH>;
	open ELE, ">$SMAP_path/report/$sample_name/$sample_type/meth.$ele_name.txt";
	print ELE "#Chrom\tStart\tEnd\tGene\tCGTimes\tCGRate\tCHGTimes\tCHGRate\tCHHTimes\tCHHRate\n";

	my (%hashcg,%hashchg,%hashchh);
	my ($tmpcg,$tmpchg,$tmpchh);
	my @bed;
	my ($avg_elcg,$avg_elchg,$avg_elchh);
	my $o;
	while(my $one=<BED>){
		chomp($one);
		@bed=split /\s+/, $one;
		
		$hashcg{$one}=0;
		my $p=0;
		while(my $lane=<CG>){
			chomp($lane);
			if($tmpcg){
				my @t=split /\s+/, $tmpcg;
				if ($t[0] ne $bed[0]){$tmpcg=0;}
				if ($t[1]<$bed[1]){$tmpcg=0;}
				elsif ($t[1]>$bed[2]){last;}
				else{
					$avg_elcg=($t[3]+$t[6])/($t[4]+$t[7]);
                      			$hashcg{$one}+=$avg_elcg;
					$element_cg{$ele_name}+=$avg_elcg;
					$ele_num_cg{$ele_name}++;
	                               	$p++;
					$tmpcg=0;
				}
			}
			$lane=~tr/\./0/;
			my @spl=split /\s+/, $lane;
			if ($spl[0] ne $bed[0]){next;}
			if ($spl[1] < $bed[1]){next;}
			if ($spl[1] > $bed[2]){$tmpcg=$lane;last;}
			$avg_elcg=($spl[3]+$spl[6])/($spl[4]+$spl[7]);
			$hashcg{$one}+=$avg_elcg;
			$element_cg{$ele_name}+=$avg_elcg;
			$ele_num_cg{$ele_name}++;
			$p++;
		}#end while <CG>
		if($p eq "0"){
       			print ELE "$one\t-\t-\t";
		}else{
			my $level=($hashcg{$one}/$p)*100;
			print ELE "$one\t$p\t";
			print ELE sprintf "%.2f", "$level";
			print ELE "\t";
		}
		##Deal CG one bed line only
	
		$hashchg{$one}=0;
		my $q=0;
		while(my $lane=<CHG>){
			chomp($lane);
			if($tmpchg){
				my @t=split /\s+/, $tmpchg;
				if ($t[0] ne $bed[0]){$tmpchg=0;}
				if ($t[1]<$bed[1]){$tmpchg=0;}
				elsif ($t[1]>$bed[2]){last;}
				else{
					$avg_elchg=($t[3]+$t[6])/($t[4]+$t[7]);
					$hashchg{$one}+=$avg_elchg;
					$element_chg{$ele_name}+=$avg_elchg;
					$ele_num_chg{$ele_name}++;
					$q++;
					$tmpchg=0;
				}
			}#end if;
			$lane=~tr/\./0/;
			my @spl=split /\s+/, $lane;
			if ($spl[0] ne $bed[0]){next;}
			if ($spl[1] < $bed[1]){next;}
			if ($spl[1] > $bed[2]){$tmpchg=$lane;last;}
			$avg_elchg=($spl[3]+$spl[6])/($spl[4]+$spl[7]);
			$hashchg{$one}+=$avg_elchg;
			$element_chg{$ele_name}+=$avg_elchg;
			$ele_num_chg{$ele_name}++;
			$q++;
		}#end while
		if($q eq "0"){
			print ELE "-\t-\t";
		}else{
			my $level=($hashchg{$one}/$q)*100;
			print ELE "$q\t";
			print ELE sprintf "%.2f", "$level";
			print ELE "\t";
		}
		#Deal CHG one BED line only
		
		$hashchh{$one}=0;	
		my $w=0;
		while(my $lane=<CHH>){	
			chomp($lane);
			if($tmpchh){
				my @t=split /\s+/, $tmpchh;
				if ($t[0] ne $bed[0]){$tmpchh=0;}
				if ($t[1]<$bed[1]){$tmpchh=0;}
				elsif ($t[1]>$bed[2]){last;}
				else{
					$avg_elchh=($t[3]+$t[6])/($t[4]+$t[7]);
					$hashchh{$one}+=$avg_elchh;
					$element_chh{$ele_name}+=$avg_elchh;
					$ele_num_chh{$ele_name}++;
					$w++;
					$tmpchh=0;
				}
			}#end if $tmpchh
			$lane=~tr/\./0/;
			my @spl=split /\s+/, $lane;
			if ($spl[0] ne $bed[0]){next;}
			if ($spl[1] < $bed[1]){next;}
			if ($spl[1] > $bed[2]){$tmpchh=$lane;last;}
			$avg_elchh=($spl[3]+$spl[6])/($spl[4]+$spl[7]);
			$hashchh{$one}+=$avg_elchh;
			$element_chh{$ele_name}+=$avg_elchh;
			$ele_num_chh{$ele_name}++;
			$w++;
		}#end while <CHH>
		if($w eq "0"){
			print ELE "-\t-\n";
		}else{
			my $level=($hashchh{$one}/$w)*100;
			print ELE "$w\t";	
			print ELE sprintf "%.2f", "$level";
			print ELE "\n";
		}
		#Deal CHH on BED line only

	}#while BED over
	close BED;
	close ELE;
}#foreach over

print AELE "#$sample_name\t$sample_type\n#Different Genome Regions\tCG Methylation level(%)\tCHG Methylation level(%)\tCHH Methylation level(%)\n";
foreach my $key(keys %element_cg){
	my $meth_elecg=($element_cg{$key}/$ele_num_cg{$key})*100;
	my $meth_elechg=($element_chg{$key}/$ele_num_chg{$key})*100;
	my $meth_elechh=($element_chh{$key}/$ele_num_chh{$key})*100;
	print AELE "$key\t";
	print AELE sprintf "%.2f", "$meth_elecg";
	print AELE "\t";
	print AELE sprintf "%.2f", "$meth_elechg";
	print AELE "\t";
	print AELE sprintf "%.2f", "$meth_elechh";
	print AELE "\n";
}
close AELE;
 
open TAR, "$target" or die "Can't open $target";
open COV, ">$SMAP_path/report/$sample_name/$sample_type/meth_coverage.info";
print COV "#Sample_Name\tSample_Type\tGC(%)\tCHG(%)\tCHH(%)\n";
print COV "$sample_name\t$sample_type\t";
while(<TAR>){
	chomp;
	my @tmp=split /\s+/, $_;
	next unless($tmp[0]);
	if($tmp[0] eq "CG"){
		my $cg_cov=($n/$tmp[1])*100;
		print COV sprintf "%.2f", "$cg_cov\t";
	}
	if($tmp[0] eq "CHG"){
		my $chg_cov=($m/$tmp[1])*100;
		print COV sprintf "%.2f", "$chg_cov\t";
	}
	if($tmp[0] eq "CHH"){
		my $chh_cov=($i/$tmp[1])*100;
		print COV sprintf "%.2f", "$chh_cov\n";
	}
}
close TAR;
close COV;

open PER, ">$SMAP_path/report/$sample_name/$sample_type/meth_class_percentage.txt";
print PER "#Sample_Name\tSample_Type\tGC(%)\tCHG(%)\tCHH(%)\n";
print PER "$sample_name\t$sample_type\t";
my $per_all=$o+$p+$q;
my $pre_cg=$o/$per_all;
my $pre_chg=$p/$per_all;
my $pre_chh=$q/$per_all;
print PER sprintf "%.2f", "$pre_cg\t";
print PER sprintf "%.2f", "$pre_chg\t";
print PER sprintf "%.2f", "$pre_chh\n";
close PER;
##---------------------------Perl End---------------------------##
