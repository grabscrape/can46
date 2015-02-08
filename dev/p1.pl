
#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Selenium::Remote::Driver;

my $driver = new Selenium::Remote::Driver;
#$driver->get('http://www.google.com');

$driver->get('http://www.mvma.ca/resources/animal-owners/find-veterinarian');

#print $driver->get_title();
# views-exposed-form-find-a-veterinarian-block

my @elements = $driver->find_element("//select");


say Dumper \@elements;

sleep 3;

#$driver->quit();


