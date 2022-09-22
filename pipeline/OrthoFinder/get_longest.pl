#!/usr/bin/env perl
use strict;
use warnings;
use Bio::SeqIO;

my %genes;

my $in = Bio::SeqIO->new(-format => 'fasta', -file => shift @ARGV || die "need a protein file input");
while(my $seq = $in->next_seq ) {
  my $id = $seq->display_id;
  my $desc = $seq->description;
  my $name = "";
  if ( $desc =~ s/\[locus_tag=([^\]]+)\]// ) {
    $seq->display_id($1);
    $name = $1;
    $seq->description("$id $desc");
  } else {
   warn("cannot find locus tag in the description: $desc\n"); 
   next;
  }
  # take either the first time we see this locus OR save only the longest on
  if ( ! exists $genes{$name} || $genes{$name}->length < $seq->length ) {
    $genes{$name} = $seq;
  }
}

my $out = Bio::SeqIO->new(-format => 'fasta');
foreach my $seq ( values %genes ) {
 $out->write_seq($seq);
}
