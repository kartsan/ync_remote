#!/usr/bin/perl -w

use strict;
use Switch;
use LWP::UserAgent;
use HTTP::Request::Common;

if ($#ARGV != 1) {
    print "\nUsage: yamaha.pl <address> <command>\n";
    exit;
}

my $address = $ARGV[0];
my $command = $ARGV[1];

my $userAgent = LWP::UserAgent->new(agent => 'perl post');

#my $message = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
#<YAMAHA_AV cmd=\"GET\"><System><Config>GetParam</Config></System></YAMAHA_AV>";

my $xmlheader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
my $putheader = "<YAMAHA_AV cmd=\"PUT\">";
my $getheader = "<YAMAHA_AV cmd=\"GET\">";
my $suffix    = "</YAMAHA_AV>";
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

sub put_message {
    my ($command) = @_;
    
    my $response = $userAgent->request(POST 'http://' . $address . '/YamahaRemoteControl/ctrl',
				       Content_Type => 'text/xml',
				       Content => $xmlheader . $putheader . $putmessages{$command} . $suffix);
    print $response->error_as_HTML unless $response->is_success;

    print $response->as_string;
}


if (defined($putmessages{$command})) {
    put_message $command;
} else {
    print "Unknown command.\n";
}

