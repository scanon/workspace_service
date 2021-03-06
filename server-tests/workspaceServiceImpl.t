use FindBin qw($Bin);
use lib $Bin.'/../lib';
use Bio::KBase::workspaceService::Impl;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;
use Data::Dumper;
my $test_count = 93;

################################################################################
#Test intiailization: setting test config, instantiating Impl, getting auth token
################################################################################
$ENV{KB_SERVICE_NAME}="workspaceService";
$ENV{KB_DEPLOYMENT_CONFIG}=$Bin."/../configs/test.cfg";
my $impl = Bio::KBase::workspaceService::Impl->new();
#Getting auth token for kbasetest user
my $tokenObj = Bio::KBase::AuthToken->new(
    user_id => 'kbasetest', password => '@Suite525'
);
my $tokenObj2 = Bio::KBase::AuthToken->new(
    user_id => 'kbasetest2', password => '@Suite525'
);
#This test should immediately die if we cannot get a valid auth token for kbasetest
if (!$tokenObj->validate() || !$tokenObj2->validate()) {
	die("Authentication of kbasetest is failing! Check connect to auth subservice!");	
}
my $oauth = $tokenObj->token();
my $oauth2 = $tokenObj2->token();
#Deleting all existing test objects (note, because we are doing this, you must NEVER use the production config)
$impl->_clearAllWorkspaces();
$impl->_clearAllWorkspaceObjects();
$impl->_clearAllWorkspaceUsers();
$impl->_clearAllWorkspaceDataObjects();
################################################################################
# Did an impl object get defined
################################################################################
ok( defined $impl, "Did an impl object get defined" );
################################################################################
# Is the impl object in the right class?
################################################################################
isa_ok( $impl, 'Bio::KBase::workspaceService::Impl', "Is it in the right class" );   
################################################################################
# Can impl perform all defined functions
################################################################################
my @impl_methods = qw(
	create_workspace
	delete_workspace
	clone_workspace
	list_workspaces
	list_workspace_objects
	set_global_workspace_permissions
	set_workspace_permissions
	save_object
	delete_workspace
	delete_object
	delete_object_permanently
	get_object
	get_objectmeta
	revert_object
	copy_object
	move_object
	has_object
	get_object_by_ref
	get_objectmeta_by_ref
	get_workspacemeta
	get_workspacepermissions
	object_history
	get_user_settings
	set_user_settings
	queue_job
	set_job_status
	get_jobs
	add_type
	get_types
	remove_type
);
can_ok($impl, @impl_methods);
################################################################################
# Can kbasetest create a workspace, and is the returned metadata correct?
################################################################################
my $meta;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$meta = $impl->create_workspace({
	        workspace => "testworkspace",
	        default_permission => "n",
	        auth => $oauth,
	});
};
ok(defined $meta, "Workspace defined");
is $meta->[0],"testworkspace";
is $meta->[1],"kbasetest";
is $meta->[3],0;
is $meta->[4],"a";
is $meta->[5],"n";
################################################################################
# Testing permissions for returning metadata
################################################################################
{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	ok(defined $impl->get_workspacemeta({auth => $oauth, 
											workspace => 'testworkspace'
											}), 
		"Can get metadata for own workspace");
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->get_workspacemeta({auth => $oauth2, 
											workspace => 'testworkspace'
											})
	} qr/User lacks permissions for the specified activity!/, 
		"Can't get metadata w/ no user obj defined and global perms = n";

	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->set_global_workspace_permissions({auth => $oauth, 
											workspace => 'testworkspace',
											new_permission => 'r'
											});
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	ok(defined $impl->get_workspacemeta({auth => $oauth2, 
											workspace => 'testworkspace'
											}),
		"Can get metadata for world readable workspace with no user obj");
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	ok(defined $impl->get_workspacemeta({workspace => 'testworkspace'}),
		"Can get metadata for world readable workspace with no auth");
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->set_global_workspace_permissions({auth => $oauth, 
											workspace => 'testworkspace',
											new_permission => 'n'
											});
	foreach my $p (qw(r w a)) { #user obj created here in mongo
		local $Bio::KBase::workspaceService::Server::CallContext = {};
		$impl->set_workspace_permissions({auth => $oauth,
											users =>['kbasetest2'],
											new_permission => $p, 
											workspace => 'testworkspace'
											});
		local $Bio::KBase::workspaceService::Server::CallContext = {};
		ok(defined $impl->get_workspacemeta({auth => $oauth2, 
												workspace => 'testworkspace'
												}),
			"Can get metadata for ws with $p permission");
	}
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->set_workspace_permissions({auth => $oauth,
										users =>['kbasetest2'],
										new_permission => 'n', 
										workspace => 'testworkspace'
										});
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->get_workspacemeta({auth => $oauth2, 
											workspace => 'testworkspace'
											})
	} qr/User lacks permissions for the specified activity!/, 
		"Can't get metadata w/ user obj defined and no permissions";
}
################################################################################
# Creating a public workspace w/o auth should fail
################################################################################
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->create_workspace({
										workspace => "test_two",
										default_permission => "n",
										})
				} qr/Authentication required: Create workspace/,
				"Creating a workspace w/o auth fails";
};
################################################################################
# Creating a public workspace w/ int as id should fail
################################################################################
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->create_workspace({
										workspace => "4",
										default_permission => "n",
										auth => $oauth2
										})
				} qr/Workspace name must contain only alphanumeric characters and cannot be an integer!/,
				"Creating a workspace w/ int as id fails";
};
################################################################################
# List workspaces returns the right workspaces
################################################################################
my $metas;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$metas = $impl->list_workspaces({auth => $oauth});
};
is scalar @$metas, 1;
ok($metas->[0]->[0] eq "testworkspace", "name matches");
################################################################################
# Workspace dies when accessed with bad token
################################################################################
my $output;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->list_workspaces({auth => "bad" });
};
is $output, undef, "list_workspaces dies with bad authentication";
################################################################################
# Can create lots of workspaces and list the right number
################################################################################
# Create a few more workspaces
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->create_workspace({workspace=>"testworkspace2",default_permission=>"r",auth=>$oauth}); 
};
ok (defined($output),"Created workspace");
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->create_workspace({workspace=>"testworkspace3",default_permission=>"r",auth=>$oauth}); 
};
ok (defined($output),"Created workspace");
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->create_workspace({workspace=>"testworkspace4",default_permission=>"n",auth=>$oauth}); 
};
ok (defined($output),"Created workspace");
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->create_workspace({workspace=>"testworkspace5",default_permission=>"n",auth=>$oauth}); 
};
ok (defined($output),"Created workspace"); 
my $workspace_list = $impl->list_workspaces({auth=>$oauth});
# Makes sure the length matches
ok(scalar(@{$workspace_list}) eq 5, "length matches");
my $idhash={};
my $ws;
foreach $ws (@{$workspace_list}) {
    $idhash->{$ws->[0]} = 1;
}
ok(defined($idhash->{testworkspace3}),
   "list_workspaces returns newly created workspace testworkspace!");

{
	my $wsl = $impl->list_workspaces({auth => $oauth2});
	ok(scalar(@{$wsl}) == 2, "Return public workspaces when excludeGlobal is undef");
	$wsl = $impl->list_workspaces({auth => $oauth2, excludeGlobal => 1});
	ok(scalar(@{$wsl}) == 0, "Don't return public workspaces when excludeGlobal = 1");
}
###############################################################################
# returns correct permissions
###############################################################################
{
	$impl->set_workspace_permissions({auth => $oauth, 
										workspace => 'testworkspace5',
										users => ['kbasetest2'],
										new_permission => 'r'});
	my $perms = $impl->get_workspacepermissions({auth => $oauth2,
												workspace => 'testworkspace5'
												});
	cmp_deeply($perms, {'kbasetest2' => 'r'}, 
			'Returns only user perm with no admin creds');
	
	$impl->set_workspace_permissions({auth => $oauth, 
										workspace => 'testworkspace5',
										users => ['kbasetest2'],
										new_permission => 'a'});
	$perms = $impl->get_workspacepermissions({auth => $oauth2,
												workspace => 'testworkspace5'
												});
	my $expected = {'kbasetest2' => 'a',
					'kbasetest' => 'a',
					'~global' => 'n'
					};
	cmp_deeply($perms, $expected, 
			'Returns all perms with admin creds');
}


################################################################################
# Cannot create world writeable workspaces
################################################################################
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->create_workspace({workspace=>"testworkspace_fake",
										default_permission=>"a",
										auth=>$oauth
										})
				} qr/Specified permission not valid!/,
				"Can't create global admin workspace"; 
};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->create_workspace({workspace=>"testworkspace_fake",
										default_permission=>"w",
										auth=>$oauth
										})
				} qr/Specified permission not valid!/,
				"Can't create global writeable workspace"; 
};
################################################################################
# Dies when attempting to create duplicate workspace
################################################################################   
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->create_workspace({workspace=>"testworkspace",default_permission=>"n",auth=>$oauth});
};
ok(!defined($output), "Dies when attempting to create duplicate workspace");
################################################################################
# Can delete workspace, but cannot delete twice, and cannot delete nonexistant workspace
################################################################################ 
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->delete_workspace({workspace=>"testworkspace",auth=>$oauth});
};
ok (defined($output),"delete succeeds");
# Does deleting a non-existent workspace fail
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->delete_workspace({workspace=>"testworkspace_foo",auth=>$oauth});
};
ok(!defined($output), "delete for non-existent ws fails");
# Does deleting a previously deleted workspace fail
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->delete_workspace({workspace=>"testworkspace",auth=>$oauth});
};
ok(!defined($output),"duplicate delete fails");
################################################################################
# Can clone workspace, but cannot clone a deleted or nonexistant workspace
################################################################################ 
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->clone_workspace({
		new_workspace => "clonetestworkspace2",
		current_workspace => "testworkspace2",
		default_permission => "n",
		auth => $oauth
	}); 
};
ok (defined($output),"clone succeeds");
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->delete_workspace({
		workspace=>"clonetestworkspace2",
		auth=>$oauth
	});
};
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->clone_workspace({
		new_workspace => "clonetestworkspace",
		current_workspace => "testworkspace",
		default_permission => "n",
		auth=> $oauth
	}); 
};
is $output, undef, "clone a deleted workspace should fail";
$output = undef;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->clone_workspace({
		new_workspace => "clonetestworkspace3",
		current_workspace => "testworkspace_foo",
		default_permission => "n",
		auth => $oauth
	}); 
};
is $output, undef, "clone a non-existent workspace should fail";
# Does the cloned workspace match the original
# Does the cloned workspace preserve permissions
################################################################################
# Cannot make workspace with bad or no permissions, and must use hash ref
################################################################################ 
eval{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$meta = $impl->create_workspace({
		workspace=>"testworkspace6",
		default_permission=>"g",
		auth=>$oauth
	});
};
isnt($@,'',"Attempt to create workspace with bad permissions fails");
eval{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$meta = $impl->create_workspace(
		"testworkspace",
		'n',
		auth=>$oauth
	);
};
isnt($@,'',"Attempt to create workspace without a hash reference  fails");
################################################################################
# Cannot change workspace owner's permissions
################################################################################ 
{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->set_workspace_permissions({workspace => 'testworkspace5',
										auth => $oauth,
										users => ['kbasetest2'],
										new_permission => 'a'
										});
										
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->set_workspace_permissions({workspace => 'testworkspace5',
										auth => $oauth2,
										users => ['kbasetest'],
										new_permission => 'n'
										});

	local $Bio::KBase::workspaceService::Server::CallContext = {};
	my $wslist = $impl->list_workspaces({auth => $oauth});
	ok(@{$wslist} == 4, "Attempt to change owner's permissions failed");
}

################################################################################
# Adding objects to workspace
################################################################################ 
note("Test Adding Objects to the workspace testworkspace");
my $wsmeta;
eval{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$wsmeta = $impl->create_workspace({
		workspace=>"testworkspace",
		default_permission=>"n",
		auth=>$oauth
	});
};
my $data = "This is my data string";
my %metadata = (a=>1,b=>2,c=>3);
my $conf = {
        id => "Test1",
        type => "TestData",
        data => $data,
        workspace => "testworkspace",
        command => "string",
        metadata => \%metadata,
        auth => $oauth
    };
my $conf1 = {
        id => "Test1",
        type => "TestData",
        workspace => "testworkspace",
        auth => $oauth
    };
my $conf2 = {
        id => "Test2",
        type => "TestData",
        workspace => "testworkspace",
        auth => $oauth
    };
my $objmeta;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->save_object($conf);
};
is(ref($objmeta),'ARRAY', "Did the save_object return an ARRAY ?");
#Adding object from URL
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->save_object({
		id => "testbiochem",
		type => "Biochemistry",
		data => "http://bioseed.mcs.anl.gov/~chenry/KbaseFiles/testKBaseBiochem.json",
		workspace => "testworkspace",
		command => "implementationTest",
		json => 1,
		compressed => 0,
		retrieveFromURL => 1,
		auth => $oauth
	});
};
ok $objmeta->[0] eq "testbiochem","save_object ran and returned testbiochem object with correct ID!";
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->get_object({
		id => "testbiochem",
		type => "Biochemistry",
		workspace => "testworkspace",
		auth => $oauth
	});
};
ok $output->{metadata}->[0] eq "testbiochem","save_object ran and returned testbiochem object with correct ID!";

# regression tests for previous behavior of inserting fields into data hash
{
	my $data = $output->{data};
	foreach my $field (qw(_wsUUID _wsID _wsType _wsWS)) {
		ok(!defined $data->{$field}, "Ensure $field not in returned data");
	}
}

#Test should fail gracefully when sending bad parameters
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$wsmeta = $impl->has_object($wsmeta);
};
isnt($@,'', "Confirm bad input parameters fails gracefully ");
#Checking if test object is present
my $bool;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$bool = $impl->has_object($conf1);
};
is($bool,1,"has_object successfully determined object Test1 exists!");
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$bool = $impl->has_object($conf2);
};
is($bool,0, "Confirm that Test2 does not exist");

# Test a few bad characters when saving IDs
{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	my $err = "Save failed for testworkspace/Unspecified/a.b" . 
		"!\nObject ID failed validation!";
	my $params = {
		workspace => "testworkspace",
		type => "Unspecified",
		auth => $oauth,
		data => {"ItsNotFunny" => "MyPantsAreOnFire"}
	};
	foreach my $c (' ', '/', '+', '(', ')', '%') {
		$params->{id} = 'a'.$c.'b';
		throws_ok {$impl->save_object($params)} qr/$err/ , 
			"shouldn't save $params->{id} - bad chars";
	}
	
	$params = {
		workspace => "testworkspace",
		type => "Unspecified",
		auth => $oauth,
		data => {"ItsNotFunny" => "MyPantsAreOnFire"},
		id => '7'
	};
	throws_ok {$impl->save_object($params)} qr/Object ID failed validation!/ , 
			"shouldn't save object with integer as id";
}

# Test a few good characters when saving IDs

{
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	my $params = {
		workspace => "testworkspace",
		type => "Unspecified",
		auth => $oauth,
		data => {"ItsNotFunny" => "MyPantsAreOnFire"}
	};
	foreach my $c ('|', '.', '0', '_', '-') {
		$params->{id} = 'a'.$c.'b';
		ok($impl->save_object($params), "should save $params->{id} ok");
	}
}


note("Retrieving test object data from database");
################################################################################
# Retreiving, moving, copying, deleting, and reverting objects 
################################################################################ 
#Retrieving test object data from database
$objmeta = [];
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->get_object($conf1);
};
is($@,"","Retrieving test object data from database");
ok $output->{metadata}->[0] eq "Test1","get_object successfully retrieved object Test1!";
note("Retrieving test object metadata from database");
#Retrieving test object metadata from database
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->get_objectmeta($conf1);
}; 
ok $objmeta->[0] eq "Test1",
	"get_objectmeta successfully retrieved metadata for Test1!";
#Copying object
$conf2 = {
	new_id => "TestCopy",
	new_workspace => "testworkspace2",
	source_id => "Test1",
	type => "TestData",
	source_workspace => "testworkspace",
	auth => $oauth
};
note("copy_object from testworkspace to testworkspace2");
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->copy_object($conf2);
};
ok $objmeta->[0] eq "TestCopy",
	"copy_object successfully returned metadata for TestCopy!";
note("move_object from testworkspace to testworkspace2");
$conf2->{'new_id'} = 'TestMove';
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->move_object($conf2);
};
ok $objmeta->[0] eq "TestMove",
	"move_object successfully returned metadata for TestMove!";
note("Delete object TestCopy from testworkspace2");
$conf2 = {
	id => "TestCopy",
	type => "TestData",
	workspace => "testworkspace2",
	auth => $oauth
};
#Deleting object
#eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->delete_object($conf2);
#};
ok $objmeta->[4] eq "delete",
	"delete_object successfully returned metadata for deleted object!";
#Reverting deleted object
#eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmeta = $impl->revert_object($conf2);
	print Dumper($objmeta);
#};
ok $objmeta->[4] =~ m/^revert/,"object successfully reverted!";
#	"revert_object successfully undeleted TestCopy!";
my $objmetas;
my $objidhash = {};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmetas = $impl->list_workspace_objects( { workspace=>"testworkspace2"});
	foreach $objmeta (@{$objmetas}) {
		$objidhash->{$objmeta->[0]} = 1;
	}
};
ok defined($objidhash->{TestCopy}),
	"list_workspace_objects now returns undeleted object TestCopy!";
note("List the objects in testworkspace");
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmetas = $impl->list_workspace_objects( { workspace=>"testworkspace",auth => $oauth});
	$objidhash = {};
	foreach $objmeta (@{$objmetas}) {
		$objidhash->{$objmeta->[0]} = 1;
	}
};
ok !defined($objidhash->{Test1}),
	"list_workspace_objects returned object list without deleted object Test1!";
#Checking that the copied objects still exist
ok !defined($objidhash->{TestCopy}),
	"list_workspace_objects returned object list without copied object TestCopy!";
ok !defined($objidhash->{TestMove}),
	"list_workspace_objects returned object list without moved result object TestMove!";
note("List the objects in testworkspace2");
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmetas = $impl->list_workspace_objects( { workspace=>"testworkspace2",auth => $oauth});
	$objidhash = {};
	foreach $objmeta (@{$objmetas}) {
		$objidhash->{$objmeta->[0]} = 1;
	}
};
ok !defined($objidhash->{Test1}),
	"list_workspace_objects returned object list without deleted object Test1!";
#Checking that the copied objects still exist
ok defined($objidhash->{TestCopy}),
	"list_workspace_objects returned object list with copied object TestCopy!";
ok defined($objidhash->{TestMove}),
	"list_workspace_objects returned object list with moved result object TestMove!";
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$output = $impl->get_objects({
		ids => ["TestCopy","TestMove","Test1"],
		types => ["TestData","TestData","TestData"],
		workspaces => ["testworkspace2","testworkspace2","testworkspace"],
		auth => $oauth
	});
};
ok defined($output), "Multiple objects retrieved at once!";
ok @{$output} == 3, "Three objects retrieved at once!";
################################################################################
# Cloning workspaces with objects
################################################################################ 
$conf2 = {
        new_workspace => "clonetestworkspace",
        current_workspace => "testworkspace2",
        default_permission => "n",
        auth => $oauth
};
#Cloning workspace
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$wsmeta = $impl->clone_workspace($conf2);
};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$objmetas = $impl->list_workspace_objects({ workspace=>"clonetestworkspace",auth => $oauth});
	$objidhash = {};
	foreach $objmeta (@{$objmetas}) {
		$objidhash->{$objmeta->[0]} = 1;
	}
};
ok defined($objidhash->{TestMove}),
	"clone_workspace successfully recreates workspace with identical objects!";

$conf = {
        workspace => "testworkspace",
        new_permission => "r",
        auth => $oauth
    };

#Changing workspace global permissions
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$wsmeta = $impl->set_global_workspace_permissions($conf);
};
is($@,'',"set_global_workspace_permissions - testworkspace to r - Command ran without errors");
ok $wsmeta->[5] eq "r",
	"set_global_workspace_permissions - Value = $wsmeta->[5] ";
my $wsmetas;
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$wsmetas = $impl->list_workspaces({});
};
is($@,'',"Logging as public");
#print Dumper($wsmetas);
$idhash = {};
foreach $wsmeta (@{$wsmetas}) {
	$idhash->{$wsmeta->[0]} = $wsmeta->[4];
}
ok defined($idhash->{testworkspace}),
	"list_workspaces reveals read oly workspace testworkspace to public!";
ok $idhash->{testworkspace} eq "r",
	"list_workspaces says public has read only privileges to testworkspace!";
################################################################################
# Testing types
################################################################################ 
#Testing the very basic type services
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->add_type({
		type => "TempTestType",
		auth => $oauth
	});
};
my $types;
my $typehash = {};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$types = $impl->get_types();
	foreach my $type (@{$types}) {
		$typehash->{$type} = 1;
	}
};
ok defined($typehash->{TempTestType}),
	"TempTestType exists!";
ok defined($typehash->{Genome}),
	"Genome exists!";
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->remove_type({
		type => "TempTestType",
		auth => $oauth
	});
};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$impl->remove_type({
		type => "Genome",
		auth => $oauth
	});
};
eval {
	local $Bio::KBase::workspaceService::Server::CallContext = {};
	$types = $impl->get_types();
	$typehash = {};
	foreach my $type (@{$types}) {
		$typehash->{$type} = 1;
	}
};
ok !defined($typehash->{TempTestType}),
	"TempTestType no longer exists!";
ok defined($typehash->{Genome}),
	"Genome exists!";

# Test types with illegal characters throw an error
{
	local local $Bio::KBase::workspaceService::Server::CallContext = {};
	throws_ok {$impl->add_type({type => 'Foo-bar', auth => $oauth})}
			qr/Type name has illegal characters!/ ,
			"shouldn't add type Foo-bar - bad chars";
}
################################################################################
#Cleanup: clearing out all objects from the workspace database
################################################################################ 
$impl->_clearAllWorkspaces();
$impl->_clearAllWorkspaceObjects();
$impl->_clearAllWorkspaceUsers();
$impl->_clearAllWorkspaceDataObjects();

done_testing($test_count);
