#!/usr/bin/env perl
use strict;
use warnings;
use Bio::Tree::Node;
use Bio::Tree::Tree;
my $Precision = 3;
#my $snp = shift || 'SNP.pairwise.tsv';
my $indel = shift || 'INDEL.pairwise.tsv';

my %matrix;

open(my $in => $indel) || die "$indel: $!";

my %indeldata;

while(<$in>) {
	next if /^FID/;
	my ($q,$t,$count) = split;
	# store reciprocal so the nums are always available
	$indeldata{$q}->{$t} = $count;
	$indeldata{$t}->{$q} = $count;
}

my $tree = &upgma(\%indeldata);
my @strains = map { $_->id } grep { $_->is_Leaf } $tree->get_nodes('breadth');
#my @strains = sort { $indeldata{$a}->{$b} } keys %indeldata;
print join("\t",'',@strains),"\n";
for( my $i = 0; $i < scalar @strains; $i++ ) {
	my @row = ($strains[$i]);
	# fix the upper and lower diagnonal computation
	for ( my $j = 0; $j < $i; $j++ ) {
			push @row, $indeldata{$strains[$i]}->{$strains[$j]};
	}
	push @row, '-';
	print join("\t", @row),"\n";
}


sub upgma{
   my ($distmat) = @_;
   # we assume type checking of $matrix has already been done
   # client shouldn't be calling this directly anyways, using the
   # make_tree method is preferred

   # algorithm, from Eddy, Durbin, Krogh, Mitchison, 1998
   # originally by Sokal and Michener 1956

   my $precisionstr = "%.$Precision"."f";

   my ($i,$j,$x,$y,@dmat,@orig,@nodes);

   my @names = keys %$distmat;
   my $c = 0;
   my @clusters = map {
       my $r = { 'id'        => $c,
                 'height'    => 0,
                 'contains'  => [$c],
             };
       $c++;
       $r;
   } @names;

   my $K = scalar @clusters;
   my (@mins,$min);
   for ( $i = 0; $i < $K; $i++ ) {
       for( $j = $i+1; $j < $K; $j++ ) {
           my $d =  $distmat->{$names[$i]}->{$names[$j]};
           # get Min here on first time around, save 1 cycle
           $dmat[$j][$i] = $dmat[$i][$j] = $d;
           $orig[$i][$j] = $orig[$j][$i] = $d;
           if ( ! defined $min || $d <= $min ) {
               if( defined $min && $min == $d ) {
                   push @mins, [$i,$j];
               } else {
                   @mins = [$i,$j];
                   $min  = $d;
               }
           }
       }
   }
   # distance between each cluster is avg distance
   # between pairs of sequences from each cluster
   while( $K > 1 ) {
       # fencepost - we already have found the $min
       # so very first time loop is executed we can skip checking
       unless( defined $min ) {
           for($i = 0; $i < $K; $i++ ) {
               for( $j = $i+1; $j < $K; $j++ ) {
                   my $dij = $dmat[$i][$j];
                   if( ! defined $min ||
                       $dij <= $min) {
                       if( defined $min &&
                           $min == $dij ) {
                           push @mins, [$i,$j];
                       } else {
                           @mins = [ $i,$j ];
                           $min = $dij;
                       }
                   }
               }
           }
       }
       # randomly break ties
       ($x,$y) = @{ $mins[int(rand(scalar @mins))] };

       # now we are going to join clusters x and y, make a new cluster

       my $node = Bio::Tree::Node->new();
       my @subids;
       for my $cid ( $x,$y ) {
           my $nid = $clusters[$cid]->{'id'};
           if( ! defined $nodes[$nid] ) {
               $nodes[$nid] = Bio::Tree::Node->new(-id => $names[$nid]);
           }
           $nodes[$nid]->branch_length
               (sprintf($precisionstr,$min/2 - $clusters[$cid]->{'height'}));
           $node->add_Descendent($nodes[$nid]);
           push @subids, @{ $clusters[$cid]->{'contains'} };
       }
       my $cluster = { 'id'       => $c++,
                       'height'   => $min / 2,
                       'contains' => [@subids],
                   };

       $K--; # we are going to drop the last node so go ahead and decrement K
       $nodes[$cluster->{'id'}] = $node;
       if ( $y != $K ) {
           $clusters[$y] = $clusters[$K];
           $dmat[$y] = $dmat[$K];
           for ( $i = 0; $i < $K; $i++ ) {
               $dmat[$i][$y] = $dmat[$y][$i];
           }
       }
       delete $clusters[$K];
       $clusters[$x] = $cluster;
       # now recalculate @dmat
       for( $i = 0; $i < $K; $i++ ) {
           if( $i != $x) {
               $dmat[$i][$x] = $dmat[$x][$i] =
                   &_upgma_distance($clusters[$i],$clusters[$x],\@orig);
           } else {
               $dmat[$i][$i] = 0;
           }
       }
       # reset so next loop iteration
       # we will find minimum distance
       @mins = ();
       $min = undef;
   }
   Bio::Tree::Tree->new(-root => $nodes[-1]);
}

# calculate avg distance between clusters - be they
# single sequences or the combination of multiple seqences
# $cluster_i and $cluster_j are the clusters to operate on
# and $distances is a matrix (arrayref of arrayrefs) of pairwise
# differences indexed on the sequence ids -
# so $distances->[0][1] is the distance between sequences 0 and 1

sub _upgma_distance {
    my ($cluster_i, $cluster_j, $distances) = @_;
    my $ilen = scalar @{ $cluster_i->{'contains'} };
    my $jlen = scalar @{ $cluster_j->{'contains'} };
    my ($d,$count);
    for( my $i = 0; $i < $ilen; $i++ ) {
        my $i_id = $cluster_i->{'contains'}->[$i];
        for( my $j = 0; $j < $jlen; $j++) {
            my $j_id = $cluster_j->{'contains'}->[$j];
            if( ! defined $distances->[$i_id][$j_id] ) {
                warn("no value for $i_id $j_id\n");
            } else {
                $d += $distances->[$i_id][$j_id];
            }
            $count++;
        }
    }
    return $d / $count;
}

