#!/usr/bin/perl -w

########################################################################
# This perl script runs the designated queue for model reconstruction
# Author: Christopher Henry
# Author email: chrisshenry@gmail.com
# Author affiliation: Mathematics and Computer Science Division, Argonne National Lab
# Date of script creation: 10/6/2009
########################################################################
use strict;
use warnings;
use JSON::XS;
use Test::More;
use Data::Dumper;
use File::Temp qw(tempfile);
use LWP::Simple;
use Config::Simple;
use Bio::KBase::AuthToken;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);

$|=1;

#Creating the error message printed whenever the user input makes no sense
my $Usage = "Scheduler must be called with the following syntax:\n".
			"scheduler <config file>\n";
#First checking to see if at least one argument has been provided
if (!defined($ARGV[0]) || $ARGV[0] eq "help") {
    print $Usage;
	exit(0);
}
my $sched = scheduler->new();
$sched->readconfig($ARGV[0]);
if (-e $sched->jobdirectory()."/schedulerPID") {
	unlink($sched->jobdirectory()."/schedulerPID");
}
my $cmd = "echo \$\$ >> ".$sched->jobdirectory()."/schedulerPID";
exec($cmd);
$sched->monitor();

#Declaring scheduler package
package scheduler;

sub new {
	my ($class,$params) = @_;
	my $self = {_directory => $params->{directory}};
    return bless $self;
}

sub directory {
    my ($self) = @_;
	return $self->{_directory};
}

sub client {
    my ($self) = @_;
    if (!defined($self->{_client})) {
    	if ($self->wsurl() eq "impl") {
			require "Bio/KBase/workspaceService/Impl.pm";
			$self->{_client} = Bio::KBase::workspaceService::Impl->new();
		} else {
    		$self->{_client} = Bio::KBase::workspaceService::Client->new($self->wsurl());
		}
    }
	return $self->{_client};
}

sub runexecutable {
	my ($self,$cmd) = @_;
	my $OutputArray;
	push(@{$OutputArray},`$cmd`);
	return $OutputArray;
}

sub runningJobs {
	my ($self) = @_;
	my $runningJobs;
	if ($self->queuetype() eq "sge") {
		my $output = $self->runexecutable("qstat");
		if (defined($output)) {
			foreach my $line (@{$output}) {
				if ($line =~ m/^(\d+)\s/) {
					$runningJobs->{$1} = 1;
				}
			}
		}
	} elsif ($self->queuetype() eq "nohup") {
		my $output = $self->runexecutable("ps -A");
		if (defined($output)) {
			foreach my $line (@{$output}) {
				if ($line =~ m/^\s+(\d+)\s.+\/([^\/]+)/) {
					my $cmd = $2;
					my $pid = $1;
					my $script = $self->script();
					if ($cmd =~ m/$script/) {
						print "Match:".$pid."|".$script."\n";
						$runningJobs->{$pid} = 1;
					}
				}
			}
		}
	}
	return $runningJobs;
}

sub monitor {
    my($self) = @_;
    my $count = $self->threads();
    my $continue = 1;
	while ($continue == 1) {
		my $runningJobs = $self->runningJobs();
		my $runningCount = keys(%{$runningJobs});
		if ($runningCount < $count) {
			my $openSlots = ($count - $runningCount);
			#Checking if outstanding queued jobs exist
			my $auth = Bio::KBase::workspaceService::Helpers::auth();
			my $jobs;
			#eval {
				local $Bio::KBase::workspaceService::Server::CallContext = {};
				$jobs = $self->client()->get_jobs({
					status => "running",
					type => $self->jobtype(),
					auth => $self->auth()
				});
				print "JOBS:".@{$jobs}."\n";
			#};
			if (defined($jobs)) {
				for (my $i=0; $i < @{$jobs}; $i++) {
					my $job = $jobs->[$i];
					if (defined($job->{jobdata}->{qsubid}) && $job->{jobdata}->{schedulerstatus} eq $self->jobstatus()) {
						my $id = $job->{jobdata}->{qsubid};
						print "Running ID ".$id."\n";
						if (!defined($runningJobs->{$id})) {
							my $input = {
								jobid => $job->{id},
								status => "error",
								auth => $self->auth(),
								currentStatus => "running"
							};
							my $filename = $self->jobdirectory()."/errors/".$self->script().".e".$id;
							print $filename."\n";
							if (-e $filename) {
								print "File found!\n";
								my $error = "";
								open (INPUT, "<", $filename);
							    while (my $Line = <INPUT>) {
							        chomp($Line);
							        $Line =~ s/\r//;
									$error .= $Line."\n";
							    }
							    close(INPUT);
								$input->{jobdata}->{error} = $error;
							}
							eval {
								local $Bio::KBase::workspaceService::Server::CallContext = {};
								my $status = $self->client()->set_job_status($input);
							};
						}
					}
				}
			}
			#eval {
				local $Bio::KBase::workspaceService::Server::CallContext = {};
				$jobs = $self->client()->get_jobs({
					status => $self->jobstatus(),
					type => $self->jobtype(),
					auth => $self->auth()
				});
			#};
			if (defined($jobs)) {
				#Queuing jobs
				while ($openSlots > 0 && @{$jobs} > 0) {
					my $job = shift(@{$jobs});
					print "Queuing job:".$job->{id}."\n";
					$self->queueJob($job);
					$openSlots--;
				}
			}
		}
		print "Sleeping...\n";
		sleep(60);
	}
}

sub printJobFile {
	my ($self,$job) = @_;
	$job->{wsurl} = $self->wsurl();
	my $JSON = JSON::XS->new();
    my $data = $JSON->encode($job);
	my $directory = File::Temp::tempdir(DIR => $self->jobdirectory()."/")."/";
	open(my $fh, ">", $directory."jobfile.json") || return;
	print $fh $data;
	close($fh);
	return $directory;
}

sub queueJob {
	my ($self,$job) = @_;
	$job->{accounttype} = $self->accounttype();
	my $jobdir = $self->printJobFile($job);
	my $pid;
	my $executable = $self->executable()." ".$jobdir;
	if ($self->queuetype() eq "sge") {
		my $cmd = "qsub -l arch=lx26-amd64 -m aes -M \"chenry\@mcs.anl.gov\" -b yes -e ".$self->jobdirectory()."/errors/ -o ".$self->jobdirectory()."/output/ ".$executable;	
		my $execOut = $self->runexecutable($cmd);
		foreach my $line (@{$execOut}) {
			if ($line =~ m/Your\sjob\s(\d+)\s/) {
				$pid = ($1+1-1);
				last;
			}
		}
	} elsif ($self->queuetype() eq "nohup") {
		my $cmd = "nohup ".$executable." > ".$jobdir."stdout.log 2> ".$jobdir."stderr.log &";
	  	system($cmd);
	  	open( my $fh, "<", $jobdir."pid");
		$pid = <$fh>;
		close($fh);
	}
	eval {
		local $Bio::KBase::workspaceService::Server::CallContext = {};
		my $status = $self->client()->set_job_status({
			jobid => $job->{id},
			status => "running",
			auth => $self->auth(),
			jobdata => {
				schedulerstatus => $self->jobstatus(),
				qsubid => $pid
			}
		});
	};
}

sub haltalljobs {
    my($self) = @_; 
	my $runningJobs = $self->runningJobs();
	foreach my $key (keys(%{$runningJobs})) {
		if ($self->queuetype() eq "sge") {
			system("qdel ".$key);
		} elsif ($self->queuetype() eq "nohup") {
			system("kill -9 ".$key);
		}		
	}
}

sub readconfig {
    my($self,$file) = @_; 
	my $c = Config::Simple->new();
	$c->read($file);
	$self->{_threads} = $c->param("scheduler.threads");
	$self->{_jobdirectory} = $c->param("scheduler.jobdirectory");
	$self->{_executable} = $c->param("scheduler.executable");
	$self->{_jobtype} = $c->param("scheduler.jobtype");
	$self->{_queuetype} = $c->param("scheduler.queuetype");
	$self->{_wsurl} = $c->param("scheduler.wsurl");
	$self->{_auth} = $c->param("scheduler.auth");
	$self->{_jobstatus} = $c->param("scheduler.jobstatus");
	$self->{_accounttype} = $c->param("scheduler.accounttype");
}

sub threads {
	 my($self) = @_;
	 return $self->{_threads};
}

sub wsurl {
	 my($self) = @_;
	 return $self->{_wsurl};
}

sub queuetype {
	 my($self) = @_;
	 return $self->{_queuetype};
}

sub jobdirectory {
	 my($self) = @_;
	 return $self->{_jobdirectory};
}

sub executable {
	 my($self) = @_;
	 return $self->{_executable};
}

sub script {
	my($self) = @_;
	if ($self->executable() =~ m/([^\/]+)$/) {
		return $1;
	}
	return "";
}

sub jobtype {
	 my($self) = @_;
	 return $self->{_jobtype};
}

sub auth {
	 my($self) = @_;
	 return $self->{_auth};
}

sub jobstatus {
	my($self) = @_;
	return $self->{_jobstatus};
}

sub accounttype {
	my($self) = @_;
	return $self->{_accounttype};
}

1;
