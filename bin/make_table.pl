#!usr/bin/perl -w
use strict;

die "Usage: prel $0 <len_10k> <fa_len> <meth_rate_cg> <meth_rate_chg> <meth_rate_chh> <out_file>\n"if(@ARGV!=6);
##perl make_table.pl 10000 hg19.fai ***.cg ***.chg ***.chh ***.out

my $len=shift;
my $fai=shift;
my $cg=shift;
my $chg=shift;
my $chh=shift;
my $out=shift;

open FA, "$fai" or die $!;
open CG, "$cg" or die $!;
open CHG, "$chg" or die $!;
open CHH, "$chh" or die $!;
open OUT, ">$out" or die $!;


################# Start deal reault ########################

my %chr;
my $watson;my $crick;my $all_me;
my %cg_wast;my %cg_cri;my %cg_all;
my %cg_wast_len;my %cg_cri_len;my %cg_all_len;
while(<CG>){
	chomp;
	next if (/\#/);
	my @sp=split /\s+/,$_;
	my $ch=$sp[0];
	my $region=int($sp[1]/$len);

	if ($sp[3] eq "." or $sp[4] eq "." or $sp[4] eq "0"){$watson=0;$sp[3]=0;$sp[4]=0;}else{$watson=$sp[3]/$sp[4];}
	if ($watson > 0.05){$cg_wast{$ch}{$region}+=$watson;$cg_wast_len{$ch}{$region}++;}
	if ($sp[6] eq "." or $sp[7] eq "." or $sp[7] eq "0"){$crick=0;$sp[6]=0;$sp[7]=0;}else{$crick=$sp[6]/$sp[7];}
	if ($crick > 0.05){$cg_cri{$ch}{$region}+=$crick;$cg_cri_len{$ch}{$region}++;}
	my $q=$sp[4]+$sp[7];
	if ($q==0){$all_me=0;}else{$all_me=($sp[3]+$sp[6])/($sp[4]+$sp[7]);}
	if ($all_me > 0.05){
		$cg_all{$ch}{$region}+=$all_me;
		if($watson > 0.05){$cg_all_len{$ch}{$region}++;}
		if ($crick > 0.05){$cg_all_len{$ch}{$region}++;}
	}
}

my %chg_wast;my %chg_cri;my %chg_all;
my %chg_wast_len;my %chg_cri_len;my %chg_all_len;
while(<CHG>){
        chomp;
        next if (/\#/);
        my @sp=split /\s+/,$_;
        my $ch=$sp[0];
	my $region=int($sp[1]/$len);
        
	if ($sp[3] eq "." or $sp[4] eq "." or $sp[4] eq "0"){$watson=0;$sp[3]=0;$sp[4]=0;}else{$watson=$sp[3]/$sp[4];}
        if ($watson > 0.05){$chg_wast{$ch}{$region}+=$watson;$chg_wast_len{$ch}{$region}++;}
        if ($sp[6] eq "." or $sp[7] eq "." or $sp[7] eq "0"){$crick=0;$sp[6]=0;$sp[7]=0;}else{$crick=$sp[6]/$sp[7];}
        if ($crick > 0.05){$chg_cri{$ch}{$region}+=$crick;$chg_cri_len{$ch}{$region}++;}
	my $q=$sp[4]+$sp[7];
        if ($q==0){$all_me=0;}else{$all_me=($sp[3]+$sp[6])/($sp[4]+$sp[7]);}
        if ($all_me > 0.05){
                $chg_all{$ch}{$region}+=$all_me;
                if($watson > 0.05){$chg_all{$ch}{$region}++;}
		if($crick > 0.05){$chg_all{$ch}{$region}++;}
        }
}

my %chh_wast;my %chh_cri;my %chh_all;
my %chh_wast_len;my %chh_cri_len;my %chh_all_len;
while(<CHH>){
        chomp;
        next if (/\#/);
        my @sp=split /\s+/,$_;
        my $ch=$sp[0];
        my $region=int($sp[1]/$len);
        
        if ($sp[3] eq "." or $sp[4] eq "." or $sp[4] eq "0"){$watson=0;$sp[3]=0;$sp[4]=0;}else{$watson=$sp[3]/$sp[4];}
        if ($watson > 0.05){$chh_wast{$ch}{$region}+=$watson;$chh_wast_len{$ch}{$region}++;}
        if ($sp[6] eq "." or $sp[7] eq "." or $sp[7] eq "0"){$crick=0;$sp[6]=0;$sp[7]=0;}else{$crick=$sp[6]/$sp[7];}
        if ($crick > 0.05){$chh_cri{$ch}{$region}+=$crick;$chh_cri_len{$ch}{$region}++;}
	my $q=$sp[4]+$sp[7];
        if ($q==0){$all_me=0;}else{$all_me=($sp[3]+$sp[6])/($sp[4]+$sp[7]);}
        if ($all_me > 0.05){
                $chh_all{$ch}{$region}+=$all_me;
                if($watson > 0.05){$chh_all_len{$ch}{$region}++;}
		if($crick > 0.05){$chh_all{$ch}{$region}++;}
        }
}

##############################################################

###################### Print OUT #############################

my $kb=$len/1000;
print OUT "#chr\t$kb";
print OUT "kb_number\tcg_all_meth\tcg_wast_meth\tcg_cri_meth\tchg_all_meth\tchg_wast_meth\tchg_cri_meth\tchh_all_meth\tchh_wast_meth\tchh_cri_meth\n";

while(<FA>){
	chomp;
	my @sp = split /\s+/,$_;
	my $chrnum=int($sp[1]/$len);
	
	my $num=0;
	while($num<=$chrnum){
		print OUT "$sp[0]\t$num\t";
		if(exists $cg_all_len{$sp[0]}{$num}){my $cg_all_me=$cg_all_len{$sp[0]}{$num}/$len;print OUT "$cg_all_me\t";}else{print OUT "0\t";}
		if(exists $cg_wast_len{$sp[0]}{$num}){my $cg_wast_me=$cg_wast_len{$sp[0]}{$num}/$len;print OUT "$cg_wast_me\t";}else{print OUT "0\t";}
		if(exists $cg_cri_len{$sp[0]}{$num}){my $cg_cri_me=$cg_cri_len{$sp[0]}{$num}/$len;print OUT "$cg_cri_me\t";}else{print OUT "0\t";}
		if(exists $chg_all_len{$sp[0]}{$num}){my $chg_all_me=$chg_all_len{$sp[0]}{$num}/$len;print OUT "$chg_all_me\t";}else{print OUT "0\t";}
        	if(exists $chg_wast_len{$sp[0]}{$num}){my $chg_wast_me=$chg_wast_len{$sp[0]}{$num}/$len;print OUT "$chg_wast_me\t";}else{print OUT "0\t";}
	        if(exists $chg_cri_len{$sp[0]}{$num}){my $chg_cri_me=$chg_cri_len{$sp[0]}{$num}/$len;print OUT "$chg_cri_me\t";}else{print OUT "0\t";}
		if(exists $chh_all_len{$sp[0]}{$num}){my $chh_all_me=$chh_all_len{$sp[0]}{$num}/$len;print OUT "$chh_all_me\t";}else{print OUT "0\t";}
	        if(exists $chh_wast_len{$sp[0]}{$num}){my $chh_wast_me=$chh_wast_len{$sp[0]}{$num}/$len;print OUT "$chh_wast_me\t";}else{print OUT "0\t";}
        	if(exists $chh_cri_len{$sp[0]}{$num}){my $chh_cri_me=$chh_cri_len{$sp[0]}{$num}/$len;print OUT "$chh_cri_me\n";}else{print OUT "0\n";}
		$num++;
	}
}

##############################################################

close FA;
close CG;
close CHG;
close CHH;
close OUT;



