#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Text::Table;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta);

my $serv = get_ws_client();
#Defining globals describing behavior
my $primaryArgs = [];
my $servercommand = "get_jobs";
my $translation = {
    status => "status"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-jobs %o',
    [ 'status|s:s', 'Job status (queued,running,done)' ],
    [ 'showerror|e', 'Set as 1 to show any errors in execution',{"default"=>0}],
    [ 'help|h|?', 'Print this usage information' ]
);
if (defined($opt->{help})) {
	print $usage;
    exit;
}
#Processing primary arguments
foreach my $arg (@{$primaryArgs}) {
	$opt->{$arg} = shift @ARGV;
	if (!defined($opt->{$arg})) {
		print $usage;
    	exit;
	}
}
#Instantiating parameters
my $params = {
	auth => auth(),
};
foreach my $key (keys(%{$translation})) {
	if (defined($opt->{$key})) {
		$params->{$translation->{$key}} = $opt->{$key};
	}
}
#Calling the server
my $output;
if ($opt->{showerror} == 0){
    eval {
        $output = $serv->$servercommand($params);
    };
}else{
    $output = $serv->$servercommand($params);
}
#Checking output and report results
if (!defined($output)) {
	print "Could not retreive job status!\n";
} else {
    if (defined($opt->{status})) {
        print "Jobs listed with status '".$opt->{status}."'\n";
    } else {
        print "Jobs listed with any status:\n";
    }
	my $tbl = [];
    for (my $i=0; $i < @{$output};$i++) {
        my $j = $output->[$i];
        push(@{$tbl},[
            $j->{id},
            $j->{workspace},
            $j->{owner},
            $j->{queuing_command},
            $j->{queuetime},
            $j->{complete}
        ]);
    }
	my $table = Text::Table->new(
    'ID', 'WS', 'Owner','Cmd','Queue time','Complete'
    );
    $table->load(@$tbl);
    print $table;
}
