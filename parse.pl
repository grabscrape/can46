#!/usr/bin/perl

use v5.10;
use Data::Dumper;
use Data::Printer;
use File::Basename;

## http://habrahabr.ru/post/227493/
use Mojo::DOM;

use Encode;
use utf8;
use strict;
use warnings;

my @fields = (
    'gnum',
    'Title',
    'Forename',
    'partial',
    'Surname',
    'Institution',
    'Street',
    'City',
    'Region',
    'Country',
    'Postcode',
#    'E-Mail',
    'Phone',
    'Fax',
    'URL'
);


my $output = `find ./Cache -type f -name \*\.html | head -10000 | grep -v Xdr-kulwinder-chhoker.html `;

my $gnum=0;
my @data = ();

if( 1 )  {
    foreach my $line (split /\n/, $output ) {
        #say $line;
        push @data, parse( $line );
    #exit 0;
    }
}

#say Dumper \@data;

open CSV, ">can46.csv";
say CSV join '|', @fields;
foreach my $d (@data) {
    say CSV join '|', map {
        $d->{$_} || ''
    } @fields;
}


my $o=`csv2excel.py --sep '|' --title --output ./can46.xls ./can46.csv`;
say "Py output: $o" if $o;

close CSV;
exit 0;

### Subs

sub parse {
    my $file = shift;
    $gnum++;
    my $data = {};

    my $file0 = basename $file;
    $file0 =~ s/\.html$//;
    $data->{URL} = 'http:http://www.mvma.ca/resources/animal-owners/find-veterinarian/'.$file0;
    $data->{gnum} = $gnum;
#return $data;
    my $body;
    open FD, $file or die "Error: $!";
    $body .= $_ for <FD>;
    close FD;
    #$body = decode('utf8',$body);

    #say $body;
    my $dom = Mojo::DOM->new( $body );

    #my $div0 = $dom->find('div#Content div.Left h1');
    my $div0 = $dom->find('div#Content');# div.Left h1');

    #say $div0;


    my $full_name = $div0->map( sub { return $_->find('div.Left h1')->[0]->text } );
    #my $full_name = $div0->find('div.Left h1')->[0]; #->text });
    #say "Full_name:\t\t", $full_name->join('Error'); #->text;

    my $fn = $full_name->join('Error');
    #say $fn;

    my ($title,$forename,$surname);
    if( $fn =~ m/^(..\.)\s+(.*)\s+(\S+)$/ ) {
        $title = $1;
        #say "\t$title";
        $data->{Title} = $title;

        $forename = $2;
        #say "\t$forename";
        $data->{Forename} = $forename;

        my @t = split /\s+/, $forename;
        $data->{partial} = scalar @t if scalar @t != 1;

        $surname = $3;
        #say "\t$surname";
        $data->{Surname} = $surname;
    }

    my $institution = $div0->map( sub { 
                        #say 'Enter';
                        my $a =$_->find('div.content h3 a');
                        if( $a->join(undef) eq '' ) {
                            #say 'here';
                            return '';# undef;
                        }
                        return $a->[0]->text if $a;
                        });

    
    #say "Institution:\t\t", $institution->join('Error');
    $data->{Institution} = $institution->join('Error').'' if $institution->join('Error') ne '';

    my $full_address = $div0->map( sub { 
                        my $a = $_->find('div.content p');
                        return '' if $a->join(undef) eq '';
                        return '' if $a->[0] =~ /Back to search/;
                        return $a->[0]; #->text;
                        });

    my $street = ''; 
    my $city = '';
    my $region = '';
    my $country = '';
    my $postcode = '';

    if( $full_address->join('Error') ) {
        my $s = $full_address->join('Error');
        my @address0 = split /\n/, $s;
        my $n  = scalar @address0;
        die 'Bad address' if( $n != 0 and $n != 4 );
        if( $n ) {
            #say ':', $address0[0], ':';
            die 'bad format address 0' if $address0[0] ne '<p>';
            die 'bad format address 3' if $address0[3] ne '            </p>';
            shift @address0;
            pop @address0;
            #say Dumper \@address0;

            my @first = map { s/^\s*//; $_ } split /<br>/, $address0[0];
            #say Dumper \@first;
            $street = $first[0];

            if( $first[1] ) {
                my ($city0, $region0) = split /\s*,\s*/, $first[1];
                $city = $city0 if $city0;
                $region = $region0 if $region0;
            }

            my $last = $address0[1];
            $last =~ s/<br>//;
            $last =~ s/^\s*//;
            #say $last;
            my ($country0, $postcode0) = split /\s+/, $last;
            $country = $country0 if $country0;
            $postcode = $postcode0 if $postcode0;
        }
        #say scalar @address0; #Dumper \@address0; #$s;
    }


    #say "Street: $street";
    $data->{Street} = $street unless $street eq '';

    #say "City: $city";
    $data->{City} = $city unless $city eq '';

    #say "Region: $region";
    $data->{Region} = $region unless $region eq '';

    #say "Country: $country";
    $data->{Country} = $country unless $country eq '';

    #say "Postcode: $postcode";
    $data->{Postcode} = $postcode unless  $postcode eq '';



    my $contacts = $div0->map( sub {
                        my $a = $_->find('div.content p')->[1];
                        return $a if $a;
                        return '';
                        }); 

    my $phone='',
    my $fax='';
    if( $contacts->join('Error') ne '' ) {
        my $s = $contacts->join('Error') ;
        if( $s =~ /Phone:\s*([-\d]+)/ ) {
            $phone= $1;
        }
        if( $s =~ /Fax:\s*([-\d]+)/ ) {
            $fax= $1;
        }
        #say 'ff:', $contacts->join('Error') 
    }

    #if(1 || $phone ne '' and $fax ne '' and $phone eq $fax ) {
        #say "Phone: $phone";
        $data->{Phone} = $phone unless $phone eq '';
        #say "Fax: $fax";
        $data->{Fax} = $fax unless $fax eq '';
    #}
return $data;
    say '-'x40;
}

