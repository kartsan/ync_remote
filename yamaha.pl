#!/usr/bin/perl -w

use strict;
use XML::Simple;
use LWP::UserAgent;
use HTTP::Request::Common;
use Data::Dumper;

my $xmlheader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
my $putheader = "<YAMAHA_AV cmd=\"PUT\">";
my $getheader = "<YAMAHA_AV cmd=\"GET\">";
my $suffix    = "</YAMAHA_AV>";
my %getmessages = (
    getconfig => "<System><Config>GetParam</Config></System>",
);
my %putmessages = (
    muteoff => "<Main_Zone><Volume><Mute>Off</Mute></Volume></Main_Zone>",
    muteon => "<Main_Zone><Volume><Mute>On</Mute></Volume></Main_Zone>",
    standby => "<System><Power_Control><Power>Standby</Power></Power_Control></System>",
    allon => "<System><Power_Control><Power>On</Power></Power_Control></System>",
    alloff => "<System><Power_Control><Power>Standby</Power></Power_Control></System>",
    mainon => "<Main_Zone><Power_Control><Power>On</Power></Power_Control></Main_Zone>",
    mainoff => "<Main_Zone><Power_Control><Power>Standby</Power></Power_Control></Main_Zone>",
    mainvolup1 => "<Main_Zone><Volume><Lvl><Val>Up 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    mainvoldown1 => "<Main_Zone><Volume><Lvl><Val>Down 1 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    mainvolup2 => "<Main_Zone><Volume><Lvl><Val>Up 2 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    mainvoldown2 => "<Main_Zone><Volume><Lvl><Val>Down 2 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    mainvolup5 => "<Main_Zone><Volume><Lvl><Val>Up 5 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    mainvoldown5 => "<Main_Zone><Volume><Lvl><Val>Down 5 dB</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone>",
    scene1 => "<Main_Zone><Scene><Scene_Load>Scene 1</Scene_Load></Scene></Main_Zone>",
    scene2 => "<Main_Zone><Scene><Scene_Load>Scene 2</Scene_Load></Scene></Main_Zone>",
    scene3 => "<Main_Zone><Scene><Scene_Load>Scene 3</Scene_Load></Scene></Main_Zone>",
    scene4 => "<Main_Zone><Scene><Scene_Load>Scene 4</Scene_Load></Scene></Main_Zone>",
    innetradio => "<Main_Zone><Input><Input_Sel>NET RADIO</Input_Sel></Input></Main_Zone>",
);

if ($#ARGV != 1) {
    print "\nUsage: yamaha.pl <address> <command>\n\n";
    print "Put commands: ";
    print "$_ " foreach (keys%putmessages);
    print "\n";
    exit;
}

my $address = $ARGV[0];
my $command = $ARGV[1];

my $userAgent = LWP::UserAgent->new(agent => 'perl post');

sub put_message {
    my ($command) = @_;
    
    my $response = $userAgent->request(POST 'http://' . $address . '/YamahaRemoteControl/ctrl',
				       Content_Type => 'text/xml',
				       Content => $xmlheader . $putheader . $putmessages{$command} . $suffix);
    print $response->error_as_HTML unless $response->is_success;

    print $response->as_string;
}

sub handle_config {
    my ($tree) = @_;

    if (defined($tree->{'Model_Name'})) {
	print "Model name: " . $tree->{'Model_Name'} . "\n";
    }
    if (defined($tree->{'System_ID'})) {
	print "System ID: " . $tree->{'System_ID'} . "\n";
    }
    if (defined($tree->{'Version'})) {
	print "Version: " . $tree->{'Version'} . "\n";
    }
    if (defined($tree->{'Feature_Existence'})) {
	print "Features: ";
	my $fe = $tree->{'Feature_Existence'};
	foreach my $key (keys %$fe) {
	    if ($fe->{$key}) {
		print $key . "  ";
	    }
	}
	print "\n";
    }
    if (defined($tree->{'Name'}{'Input'})) {
	print "Input(Name): ";
	my $inp = $tree->{'Name'}{'Input'};
	foreach my $key (keys %$inp) {
	    print $key . "(" . $inp->{$key} . ")  ";
	}
	print "\n";
    }

}

sub handle_system {
    my ($tree) = @_;

    if (defined($tree->{'Config'})) {
	handle_config $tree->{'Config'};
    }
}

sub get_message {
    my ($command) = @_;

    my $response = $userAgent->request(POST 'http://' . $address . '/YamahaRemoteControl/ctrl',
				       Content_Type => 'text/xml',
				       Content => $xmlheader . $getheader . $getmessages{$command} . $suffix);
#    print $response->error_as_HTML unless $response->is_success;

#    print $response->as_string;

    if ($response->is_success) {
	my $xml = new XML::Simple;
	my $tree = $xml->XMLin($response->content);

	if (defined($tree->{'System'})) {
	    handle_system $tree->{'System'};
	}
    }
}


if (defined($putmessages{$command})) {
    put_message $command;
} elsif (defined($getmessages{$command})) {
    get_message $command;
} else {
    print "Unknown command.\n";
}

