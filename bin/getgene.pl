#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <dmr.out.Upstream2k> <gene_name.uniq> <dmr.out.gene>\n"if(@ARGV!=3); 

open IN, "$ARGV[0]" or die $!;
open OUT, ">$ARGV[1]" or die $!;
open LIST, ">$ARGV[2]" or die $!;

my $title=<IN>;
print OUT "Gene\tTimes\n";
print LIST "$title";

my %hash;

while (<IN>){
	chomp;
	my @sp = split /\s/, $_;
	my $len=@sp;
	if($len >10){
		my $i=10;
		while($i < $len){
		#	print $sp[$i];exit;
			$sp[$i]=~/.*\,.*\|(.*)\:.*/;
			$hash{$1}++;
			$i++
		}
		print LIST "$_\n";
	}
}

foreach my $key (sort { $hash{$b} <=> $hash{$a} } keys %hash){
	print OUT "$key\t$hash{$key}\n";
}

close IN;
close OUT;
close LIST;
