use FindBin qw($Bin);
use lib $Bin.'/../lib';
use Bio::KBase::AuthToken;
use Bio::KBase::workspaceService::Client;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;
my $test_count = 24;

#  Test 1 - Can a new client object be created without parameters? 
#Creating new workspace services implementation connected to testdb

# Create an authorization token
my $token = Bio::KBase::AuthToken->new(
    user_id => 'kbasetest', password => '@Suite525'
);
my $url = "http://localhost:7058";
#my $url = "http://kbase.us/services/workspace";
my $client = Bio::KBase::workspaceService::Client->new($url);
ok( defined $client, "Did an impl object get defined" );    

#  Test 2 - Is the impl object in the right class?
isa_ok( $client, 'Bio::KBase::workspaceService::Client', "Is it in the right class" );

my $oauth_token = $token->token();

# make a client with embedded authorization
my $authed_client = Bio::KBase::workspaceService::Client->new($url,
						user_id => 'kbasetest', password => '@Suite525');

# Can I delete a workspace
eval { $client->delete_workspace({workspace=>"testworkspace1",auth=>$oauth_token})  };

# Can I create a test workspace
my $wsmeta1 = $client->create_workspace({workspace=>"testworkspace1",default_permission=>"n",auth=>$oauth_token});


ok(defined $wsmeta1, "workspace defined");

ok($wsmeta1->[0] eq "testworkspace1", "created workspace");

ok($wsmeta1->[1] eq "kbasetest", "user == kbasetest");

ok($wsmeta1->[3] eq 0, "ws has no objects");

ok($wsmeta1->[4] eq "a", "ws has a user perms");

ok($wsmeta1->[5] eq "n", "ws has n global perms");

# Do embedded auth and parameter auth list the same workspaces

my $workspace_list = $client->list_workspaces({auth=>$oauth_token});
my $authed_list = $authed_client->list_workspaces({});
for my $l (($workspace_list, $authed_list)) {
	my $idhash1={};
	foreach my $ws1 (@{$l}) {
	    $idhash1->{$ws1->[0]} = 1;
	}
	ok(defined($idhash1->{testworkspace1}),
	   "list_workspaces returns newly created workspace testworkspace1!");
}

# no auth can't see the workspace

{
	my $no_auth_ws_list = $client->list_workspaces({});
	my $idhash1={};
	foreach my $ws1 (@{$no_auth_ws_list}) {
	    $idhash1->{$ws1->[0]} = 1;
	}
	ok(!defined($idhash1->{testworkspace1}),
	   "list_workspaces doesn't return testworkspace1 w/o auth");
}

# Create a few more workspaces
lives_ok { $client->create_workspace({workspace=>"testworkspace2",default_permission=>"r",auth=>$oauth_token}); } "create read-only ws";
lives_ok { $client->create_workspace({workspace=>"testworkspace3",default_permission=>"r",auth=>$oauth_token}); } "create read-only ws #2";
lives_ok { $client->create_workspace({workspace=>"testworkspace4",default_permission=>"n",auth=>$oauth_token}); } "create no perm ws";
lives_ok { $client->create_workspace({workspace=>"testworkspace5",default_permission=>"n",auth=>$oauth_token}); } "create no perm ws #2";

$workspace_list = $client->list_workspaces({auth=>$oauth_token});

# Makes sure the length matches (at least 5 - there may be other workspaces prior to this test)
ok(scalar(@{$workspace_list}) >= 5, "length matches");


my $idhash={};
my $ws;
foreach $ws (@{$workspace_list}) {
    $idhash->{$ws->[0]} = 1;
}

ok(defined($idhash->{testworkspace3}),
   "list_workspaces returns newly created workspace testworkspace3!");
    
# Does creating a duplicate workspace fail

dies_ok { $client->create_workspace({workspace=>"testworkspace1",default_permission=>"n",auth=>$oauth_token}) } "create duplicate fails";


# Can I delete a workspace
lives_ok { $client->delete_workspace({workspace=>"testworkspace1",auth=>$oauth_token})  } "delete succeeds";
# Does deleting a non-existent workspace fail
dies_ok { $client->delete_workspace({workspace=>"testworkspace_foo",auth=>$oauth_token})  } "delete for non-existent ws fails";
# Does deleting a previously deleted workspace fail
dies_ok { $client->delete_workspace({workspace=>"testworkspace1",auth=>$oauth_token})  } "duplicate delete fails";

# Can I clone a workspace
lives_ok{ $client->clone_workspace({
            new_workspace => "clonetestworkspace2",
            current_workspace => "testworkspace2",
            default_permission => "n",
            auth => $oauth_token
          }); 
        } "clone succeeds";
$client->delete_workspace({workspace=>"clonetestworkspace2", auth=>$oauth_token});


# Does cloning a deleted workspace fail
dies_ok{ $client->clone_workspace({
            new_workspace => "clonetestworkspace1",
            current_workspace => "testworkspace1",
            default_permission => "n",
            auth => $oauth_token
          }); 
        } "clone a deleted workspace should fail";


# Does cloning a non-existent workspace fail
dies_ok{ $client->clone_workspace({
            new_workspace => "clonetestworkspace3",
            current_workspace => "testworkspace_foo",
            default_permission => "n",
            auth => $oauth_token
          }); 
        } "clone a non-existent workspace should fail";

# Does the cloned workspace match the original

# Does the cloned workspace preserve permissions

# Can I list workspace objects

# Can I write to a read only workspace?

# Test multiple users

# Clean up
$client->delete_workspace({workspace=>"testworkspace2", auth=>$oauth_token});
$client->delete_workspace({workspace=>"testworkspace3", auth=>$oauth_token});
$client->delete_workspace({workspace=>"testworkspace4", auth=>$oauth_token});
$client->delete_workspace({workspace=>"testworkspace5", auth=>$oauth_token});

done_testing($test_count);
