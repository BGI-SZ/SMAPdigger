#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <CDS.meth.zones> <Upstream2k.meth.zones> <Downstream2k.meth.zones> <Intron.meth.zones> <element.50zone.txt>\n" if (@ARGV != 5);

open CDS, "$ARGV[0]" or die "Can't open $ARGV[0]";
open IN, "$ARGV[1]" or die "Can't open $ARGV[1]";
open UP, "$ARGV[2]" or die "Can't open $ARGV[2]";
open DOWN, "$ARGV[3]" or die "Can't open $ARGV[3]";
open OUT, ">$ARGV[4]" or die "Can't open $ARGV[4]";

while(<CDS>){
	chomp;
	my @sp=split /\s+/, $_;
	if(@sp != 55){next;}
	else{
		print OUT "$sp[0]\t$sp[1]\tCDS\t$sp[2]\-$sp[3]";
		my $i=5;
		while($i<=54){
			print OUT "\t$sp[$i]";
			$i++;
		}
	}
	print OUT "\n";
}
close CDS;

while(<IN>){
	chomp;
	my @sp=split /\s+/, $_;
	if(@sp != 55){next;}
	else{
		print OUT "$sp[0]\t$sp[1]\tCDS\t$sp[2]\-$sp[3]";
		my $i=5;
		while($i<=54){
			print OUT "\t$sp[$i]";
			$i++;
		}
	}
	print OUT "\n";
}
close IN;

while(<UP>){
	chomp;
	my @sp=split /\s+/, $_;
	if(@sp != 55){next;}
	else{
		print OUT "$sp[0]\t$sp[1]\tCDS\t$sp[2]\-$sp[3]";
		my $i=5;
		while($i<=54){
			print OUT "\t$sp[$i]";
			$i++;
		}
	}
	print OUT "\n";
}
close UP;

while(<DOWN>){
	chomp;
	my @sp=split /\s+/, $_;
	if(@sp != 55){next;}
	else{
		print OUT "$sp[0]\t$sp[1]\tCDS\t$sp[2]\-$sp[3]";
		my $i=5;
		while($i<=54){
			print OUT "\t$sp[$i]";
			$i++;
		}
	}
	print OUT "\n";
}
close DOWN;

close OUT;
