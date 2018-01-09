#!usr/bin/perl -w
use strict;

die "Usage:\tperl $0 <SMAP_path> <sample_name> <sample_type> <bed_dir> <out_path>\n"if(@ARGV!=5);

my $SMAP_path=$ARGV[0];
my $sample_name=$ARGV[1];
my $sample_type=$ARGV[2];
my $beddir=$ARGV[3];
my $out_path=$ARGV[4];

my $bed_path=`ls $beddir/*`;
my @link=split /\n/, $bed_path;
my @color=('blue','green2','gold1','cyan2','magenta','darkorange2','brown1','red','yellow');
my $i=0;

foreach(@link){
	open BED, "$_" or die $!;
	$_=~/(.*)\.bed/;
	my $ele_name=(split /\//,$1)[-1];

	open OUT,">$out_path/$ele_name.dmr.out";
	print OUT "chr\tpos_start\tpos_end\tshared_num/methy_in_normal/methy_in_tumor/pos_num\ttumor_methy_num/tumor_NONE_methy_num\ttumor_methy_ratio\tnormal_methy_num/normal_NONE_methy_num\tnormal_methy_ratio\tchisq.test_p-value\tt.test_p-value\tPlotColor\n";
	die"color isn't enough\n"if($i>@color);
	my $PlotColor=$color[$i];
	$i++;
	
	while (<BED>){
		chomp;
		my @array = split/\t/,$_;
		my $chr = $array[0];
		my $start = $array[1];
		open DMR,"$SMAP_path/$sample_name/$sample_type/DMR/dmr.out" or die($!);
		my $Head = <DMR>;
		while (<DMR>){
			chomp;
			my @Array = split/\t/,$_;
			my $Chr = $Array[0];
			my $Start = $Array[1];
			my $End = $Array[2];
			my $Cop1 = $Array[3];
			my $Methy_None = $Array[4];
			my $Tumor_methy_ratio = $Array[5];
			my $Normal_None = $Array[6];
			my $Normal_methy_ratio = $Array[7];
			my $chisq_test_p_value = $Array[8];
			my $t_test_p_value = $Array[9];
			if (($Chr eq $chr) and ($Start <= $start)){
			print OUT "$Chr\t$Start\t$End\t$Cop1\t$Methy_None\t$Tumor_methy_ratio\t$Normal_None\t$Normal_methy_ratio\t$chisq_test_p_value\t$t_test_p_value\t$PlotColor\n";
			}
		}
		close DMR;
	}
	close BED;
	close OUT;
}

