#!/usr/bin/perl -w
use strict;
use File::Basename qw/basename dirname/;
use FindBin qw/$RealScript $RealBin/;
use Getopt::Long;

die "Usage: perl $0 <SMAP_path> <sample_name> <sample_type> <ref_fasta>\n"if(@ARGV!=4);

my $SMAP_path=shift;
my $sample_name=shift;
my $sample_type=shift;
my $fasta=shift;
my $outdir="$SMAP_path/report/$sample_name/$sample_type";
`mkdir -p $outdir` unless(-d $outdir);

open REF, "$fasta" or die $!;

my %ref;
my $chr;
while(<REF>){
	chomp;
	if(/\>/){$_=~/\>(.*)/;$chr=$1;}
	else{$ref{$chr}.=$_;}
}
close REF;

my @type=('cg','chg','chh');
my $i=0;
	
while($i<3){
	open ME, "$SMAP_path/$sample_name/$sample_type/ASM/meth.$type[$i]" or die $!;
	open BP, ">$outdir/$type[$i].9bp" or die $!;
	
	my ($avg,$meth,$bp);
	my %str;

	while(<ME>){
		chomp;
              	next if(/\#/);
		$_=~tr/\./0/;
                my @sp=split /\s+/,$_;
		$meth=$sp[3]+$sp[6];
              	$avg= ($sp[3]+$sp[6])/($sp[4]+$sp[7]);
		if($meth>=2){
			if($avg>=0.1){
			$bp=substr($ref{$sp[0]},$sp[1]-4,9);
			$bp=~tr/agctn/AGCTN/;
			$str{$bp}++;
			}
		}
	}
	foreach my $key(sort{$str{$b}<=>$str{$a}} keys %str){
		print BP "$key\t";
		print BP $str{$key};
		print BP "\n";
	}
			
	close ME;
	close BP;

	open BP, "$outdir/$type[$i].9bp" or die $!;
	open OUT, ">$outdir/$type[$i].9bp.frequence.xls" or die $!;
	my $A1=0; my $A2=0; my $A3=0; my $A4=0; my $A5=0; my $A6=0; my $A7=0; my $A8=0; my $A9=0;
	my $T1=0; my $T2=0; my $T3=0; my $T4=0; my $T5=0; my $T6=0; my $T7=0; my $T8=0; my $T9=0;
	my $C1=0; my $C2=0; my $C3=0; my $C4=0; my $C5=0; my $C6=0; my $C7=0; my $C8=0; my $C9=0;
	my $G1=0; my $G2=0; my $G3=0; my $G4=0; my $G5=0; my $G6=0; my $G7=0; my $G8=0; my $G9=0;
	my $Times = 0;

	while (<BP>){
		chomp;
        	my @array = split /\t/,$_;
        	my $seq = $array[0];
        	my $times = $array[1];
        	$Times += $times;

        	my $one = substr($seq,0,1);      #use &sub (update the routine later)
        	if ($one eq "A"){ $A1 += $times; }
        	elsif ($one eq "T"){ $T1 += $times; }
        	elsif ($one eq "C"){ $C1 += $times; }
        	else{ $G1 += $times; }

		my $two = substr($seq,1,1);
		if ($two eq "A"){ $A2 += $times; }
        	elsif ($two eq "T"){ $T2 += $times; }
        	elsif ($two eq "C"){ $C2 += $times; }
        	else{ $G2 += $times; }

        	my $three = substr($seq,2,1);
        	if ($three eq "A"){ $A3 += $times; }
        	elsif ($three eq "T"){ $T3 += $times; }
        	elsif ($three eq "C"){ $C3 += $times; }
        	else{ $G3 += $times; }

		my $four = substr($seq,3,1);
		if ($four eq "A"){ $A4 += $times; }
		elsif ($four eq "T"){ $T4 += $times; }
		elsif ($four eq "C"){ $C4 += $times; }
		else{ $G4 += $times; }

		my $five = substr($seq,4,1);
		if ($five eq "A"){ $A5 += $times; }
		elsif ($five eq "T"){ $T5 += $times; }
		elsif ($five eq "C"){ $C5 += $times; }
		else{ $G5 += $times; }

        	my $six = substr($seq,5,1);
        	if ($six eq "A"){ $A6 += $times; }
        	elsif ($six eq "T"){ $T6 += $times; }
        	elsif ($six eq "C"){ $C6 += $times; }
        	else { $G6 += $times; }

		my $seven = substr($seq,6,1);
		if ($seven eq "A"){ $A7 += $times; }
		elsif ($seven eq "T"){ $T7 += $times; }
        	elsif ($seven eq "C"){ $C7 += $times; }
        	else { $G7 += $times;}

        	my $eight = substr($seq,7,1);
        	if ($eight eq "A"){ $A8 += $times; }
        	elsif ($eight eq "T"){ $T8 += $times; }
        	elsif ($eight eq "C"){ $C8 += $times; }
        	else{ $G8 += $times; }

       		my $nine = substr($seq,8,1);
        	if ($nine eq "A"){ $A9 += $times; }
        	elsif ($nine eq "T"){ $T9 += $times; }
        	elsif ($nine eq "C"){ $C9 += $times; }
        	else{ $G9 += $times; }

	}#end <BP>
	close BP;

	my $rate_A1=$A1/$Times; my $rate_T1=$T1/$Times; my $rate_C1=$C1/$Times; my $rate_G1=$G1/$Times;
	my $rate_A2=$A2/$Times; my $rate_T2=$T2/$Times; my $rate_C2=$C2/$Times; my $rate_G2=$G2/$Times;
	my $rate_A3=$A3/$Times; my $rate_T3=$T3/$Times; my $rate_C3=$C3/$Times; my $rate_G3=$G3/$Times;
	my $rate_A6=$A6/$Times; my $rate_T6=$T6/$Times; my $rate_C6=$C6/$Times; my $rate_G6=$G6/$Times;
	my $rate_A7=$A7/$Times; my $rate_T7=$T7/$Times; my $rate_C7=$C7/$Times; my $rate_G7=$G7/$Times;
	my $rate_A8=$A8/$Times; my $rate_T8=$T8/$Times; my $rate_C8=$C8/$Times; my $rate_G8=$G8/$Times;
	my $rate_A9=$A9/$Times; my $rate_T9=$T9/$Times; my $rate_C9=$C9/$Times; my $rate_G9=$G9/$Times;
	print OUT "$rate_A1\t$rate_A2\t$rate_A3\t0\t0\t$rate_A6\t$rate_A7\t$rate_A8\t$rate_A9\n";
	print OUT "$rate_C1\t$rate_C2\t$rate_C3\t1\t0\t$rate_C6\t$rate_C7\t$rate_C8\t$rate_C9\n";
	print OUT "$rate_G1\t$rate_G2\t$rate_G3\t0\t1\t$rate_G6\t$rate_G7\t$rate_G8\t$rate_G9\n";
	print OUT "$rate_T1\t$rate_T2\t$rate_T3\t0\t0\t$rate_T6\t$rate_T7\t$rate_T8\t$rate_T9\n";

	$i++;
}

