%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2009-2011. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%

%%%-------------------------------------------------------------------
%%% File: ct_error_SUITE
%%%
%%% Description: 
%%% Test various errors in Common Test suites.
%%%
%%% The suites used for the test are located in the data directory.
%%%-------------------------------------------------------------------
-module(ct_hooks_SUITE).

-compile(export_all).

-include_lib("test_server/include/test_server.hrl").
-include_lib("common_test/include/ct_event.hrl").

-define(eh, ct_test_support_eh).

%%--------------------------------------------------------------------
%% TEST SERVER CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Description: Since Common Test starts another Test Server
%% instance, the tests need to be performed on a separate node (or
%% there will be clashes with logging processes etc).
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    DataDir = ?config(data_dir, Config),
    TestDir = filename:join(DataDir,"cth/tests/"),
    CTHs = filelib:wildcard(filename:join(TestDir,"*_cth.erl")),
    io:format("CTHs: ~p",[CTHs]),
    [io:format("Compiling ~p: ~p",
	    [FileName,compile:file(FileName,[{outdir,TestDir},debug_info])]) ||
	FileName <- CTHs],
    ct_test_support:init_per_suite([{path_dirs,[TestDir]} | Config]).

end_per_suite(Config) ->
    ct_test_support:end_per_suite(Config).

init_per_testcase(TestCase, Config) ->
    ct_test_support:init_per_testcase(TestCase, Config).

end_per_testcase(TestCase, Config) ->
    ct_test_support:end_per_testcase(TestCase, Config).


suite() ->
    [{timetrap,{seconds,20}}].

all() ->
    all(suite).

all(suite) -> 
    lists:reverse(
      [
       one_cth, two_cth, faulty_cth_no_init, faulty_cth_id_no_init,
       faulty_cth_exit_in_init, faulty_cth_exit_in_id,
       faulty_cth_exit_in_init_scope_suite, minimal_cth, 
       minimal_and_maximal_cth, faulty_cth_undef, 
       scope_per_suite_cth, scope_per_group_cth, scope_suite_cth,
       scope_per_suite_state_cth, scope_per_group_state_cth, 
       scope_suite_state_cth,
       fail_pre_suite_cth, fail_post_suite_cth, skip_pre_suite_cth,
       skip_post_suite_cth, recover_post_suite_cth, update_config_cth,
       state_update_cth, options_cth, same_id_cth, 
       fail_n_skip_with_minimal_cth
      ]
    )
	.


%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%%%-----------------------------------------------------------------
%%% 
one_cth(Config) when is_list(Config) -> 
    do_test(one_empty_cth, "ct_cth_empty_SUITE.erl",[empty_cth], Config).

two_cth(Config) when is_list(Config) -> 
    do_test(two_empty_cth, "ct_cth_empty_SUITE.erl",[empty_cth,empty_cth],
	    Config).

faulty_cth_no_init(Config) when is_list(Config) ->
    do_test(faulty_cth_no_init, "ct_cth_empty_SUITE.erl",[askjhdkljashdkaj],
	    Config,{error,"Failed to start CTH, see the "
		   "CT Log for details"}).

faulty_cth_id_no_init(Config) when is_list(Config) ->
    do_test(faulty_cth_id_no_init, "ct_cth_empty_SUITE.erl",[id_no_init_cth],
	    Config,{error,"Failed to start CTH, see the "
		   "CT Log for details"}).

minimal_cth(Config) when is_list(Config) ->
    do_test(minimal_cth, "ct_cth_empty_SUITE.erl",[minimal_cth],Config).

minimal_and_maximal_cth(Config) when is_list(Config) ->
    do_test(minimal_and_maximal_cth, "ct_cth_empty_SUITE.erl",
	    [minimal_cth, empty_cth],Config).
    
faulty_cth_undef(Config) when is_list(Config) ->
    do_test(faulty_cth_undef, "ct_cth_empty_SUITE.erl",
	    [undef_cth],Config).

faulty_cth_exit_in_init_scope_suite(Config) when is_list(Config) ->
    do_test(faulty_cth_exit_in_init_scope_suite, 
	    "ct_exit_in_init_scope_suite_cth_SUITE.erl",
	    [],Config).

faulty_cth_exit_in_init(Config) when is_list(Config) ->
    do_test(faulty_cth_exit_in_init, "ct_cth_empty_SUITE.erl",
	    [crash_init_cth], Config,
	    {error,"Failed to start CTH, see the "
	     "CT Log for details"}).

faulty_cth_exit_in_id(Config) when is_list(Config) ->
    do_test(faulty_cth_exit_in_id, "ct_cth_empty_SUITE.erl",
	    [crash_id_cth], Config,
	    {error,"Failed to start CTH, see the "
	     "CT Log for details"}).

scope_per_suite_cth(Config) when is_list(Config) ->
    do_test(scope_per_suite_cth, "ct_scope_per_suite_cth_SUITE.erl",
	    [],Config).

scope_suite_cth(Config) when is_list(Config) ->
    do_test(scope_suite_cth, "ct_scope_suite_cth_SUITE.erl",
	    [],Config).

scope_per_group_cth(Config) when is_list(Config) ->
    do_test(scope_per_group_cth, "ct_scope_per_group_cth_SUITE.erl",
	    [],Config).

scope_per_suite_state_cth(Config) when is_list(Config) ->
    do_test(scope_per_suite_state_cth, "ct_scope_per_suite_state_cth_SUITE.erl",
	    [],Config).

scope_suite_state_cth(Config) when is_list(Config) ->
    do_test(scope_suite_state_cth, "ct_scope_suite_state_cth_SUITE.erl",
	    [],Config).

scope_per_group_state_cth(Config) when is_list(Config) ->
    do_test(scope_per_group_state_cth, "ct_scope_per_group_state_cth_SUITE.erl",
	    [],Config).

fail_pre_suite_cth(Config) when is_list(Config) ->
    do_test(fail_pre_suite_cth, "ct_cth_empty_SUITE.erl",
	    [fail_pre_suite_cth],Config).

fail_post_suite_cth(Config) when is_list(Config) ->
    do_test(fail_post_suite_cth, "ct_cth_empty_SUITE.erl",
	    [fail_post_suite_cth],Config).

skip_pre_suite_cth(Config) when is_list(Config) ->
    do_test(skip_pre_suite_cth, "ct_cth_empty_SUITE.erl",
	    [skip_pre_suite_cth],Config).

skip_post_suite_cth(Config) when is_list(Config) ->
    do_test(skip_post_suite_cth, "ct_cth_empty_SUITE.erl",
	    [skip_post_suite_cth],Config).

recover_post_suite_cth(Config) when is_list(Config) ->
    do_test(recover_post_suite_cth, "ct_cth_fail_per_suite_SUITE.erl",
	    [recover_post_suite_cth],Config).

update_config_cth(Config) when is_list(Config) ->
    do_test(update_config_cth, "ct_update_config_SUITE.erl",
	    [update_config_cth],Config).

state_update_cth(Config) when is_list(Config) ->
    do_test(state_update_cth, "ct_cth_fail_one_skip_one_SUITE.erl",
	    [state_update_cth,state_update_cth],Config).

options_cth(Config) when is_list(Config) ->
    do_test(options_cth, "ct_cth_empty_SUITE.erl",
	    [{empty_cth,[test]}],Config).
    
same_id_cth(Config) when is_list(Config) ->
    do_test(same_id_cth, "ct_cth_empty_SUITE.erl",
	    [same_id_cth,same_id_cth],Config).

fail_n_skip_with_minimal_cth(Config) when is_list(Config) ->
    do_test(fail_n_skip_with_minimal_cth, "ct_cth_fail_one_skip_one_SUITE.erl",
	    [minimal_terminate_cth],Config).

%%%-----------------------------------------------------------------
%%% HELP FUNCTIONS
%%%-----------------------------------------------------------------

do_test(Tag, SWC, CTHs, Config) ->
    do_test(Tag, SWC, CTHs, Config, ok).
do_test(Tag, SWC, CTHs, Config, {error,_} = Res) ->
    do_test(Tag, SWC, CTHs, Config, Res, 1);
do_test(Tag, SWC, CTHs, Config, Res) ->
    do_test(Tag, SWC, CTHs, Config, Res, 2).

do_test(Tag, SuiteWildCard, CTHs, Config, Res, EC) ->
    
    DataDir = ?config(data_dir, Config),
    Suites = filelib:wildcard(
	       filename:join([DataDir,"cth/tests",SuiteWildCard])),
    {Opts,ERPid} = setup([{suite,Suites},
			  {ct_hooks,CTHs},{label,Tag}], Config),
    Res = ct_test_support:run(Opts, Config),
    Events = ct_test_support:get_events(ERPid, Config),

    ct_test_support:log_events(Tag, 
			       reformat(Events, ?eh), 
			       ?config(priv_dir, Config)),

    TestEvents = events_to_check(Tag, EC),
    ok = ct_test_support:verify_events(TestEvents, Events, Config).

setup(Test, Config) ->
    Opts0 = ct_test_support:get_opts(Config),
    Level = ?config(trace_level, Config),
    EvHArgs = [{cbm,ct_test_support},{trace_level,Level}],
    Opts = Opts0 ++ [{event_handler,{?eh,EvHArgs}}|Test],
    ERPid = ct_test_support:start_event_receiver(Config),
    {Opts,ERPid}.

reformat(Events, EH) ->
    ct_test_support:reformat(Events, EH).
%reformat(Events, _EH) ->
%    Events.

%%%-----------------------------------------------------------------
%%% TEST EVENTS
%%%-----------------------------------------------------------------
events_to_check(Test) ->
    %% 2 tests (ct:run_test + script_start) is default
    events_to_check(Test, 2).

events_to_check(_, 0) ->
    [];
events_to_check(Test, N) ->
    test_events(Test) ++ events_to_check(Test, N-1).

test_events(one_empty_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{empty_cth,id,[[]]}},
     {?eh,cth,{empty_cth,init,[{'_','_','_'},[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{empty_cth,pre_init_per_suite,
	       [ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{empty_cth,post_init_per_suite,
	       [ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,cth,{empty_cth,pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{empty_cth,post_end_per_testcase,[test_case,'$proplist','_',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,cth,{empty_cth,pre_end_per_suite,
	       [ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{empty_cth,post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{empty_cth,terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(two_empty_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(faulty_cth_no_init) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(faulty_cth_id_no_init) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {negative,{?eh,tc_start,'_'},
      {?eh,test_done,{'DEF','STOP_TIME'}}},
     {?eh,stop_logging,[]}
    ];

test_events(minimal_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {negative,{?eh,cth,{'_',id,['_',[]]}},
      {?eh,cth,{'_',init,['_',[]]}}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(minimal_and_maximal_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {negative,{?eh,cth,{'_',id,['_',[]]}},
      {?eh,cth,{'_',init,['_',[]]}}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(faulty_cth_undef) ->
    FailReasonStr = "undef_cth:pre_init_per_suite/3 CTH call failed",
    FailReason = {ct_cth_empty_SUITE,init_per_suite,
		  {failed,FailReasonStr}},
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,
		  {failed, {error,FailReasonStr}}}},
     {?eh,cth,{'_',on_tc_fail,'_'}},

     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,test_case,
			{failed, FailReason}}},
     {?eh,cth,{'_',on_tc_skip,'_'}},
     
     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,end_per_suite,
			{failed, FailReason}}},
     {?eh,cth,{'_',on_tc_skip,'_'}},
     
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(faulty_cth_exit_in_init_scope_suite) ->
    [{?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{'_',init_per_suite}},
     {?eh,cth,{empty_cth,init,['_',[]]}},
     {?eh,tc_done,
      {ct_exit_in_init_scope_suite_cth_SUITE,init_per_suite,
       {failed,
	{error,
	 "Failed to start CTH, see the CT Log for details"}}}},
     {?eh,tc_auto_skip,
      {ct_exit_in_init_scope_suite_cth_SUITE,test_case,
       {failed,
	{ct_exit_in_init_scope_suite_cth_SUITE,init_per_suite,
	 {failed,
	  "Failed to start CTH, see the CT Log for details"}}}}},
     {?eh,tc_auto_skip,
      {ct_exit_in_init_scope_suite_cth_SUITE,end_per_suite,
       {failed,
	{ct_exit_in_init_scope_suite_cth_SUITE,init_per_suite,
	 {failed,
	  "Failed to start CTH, see the CT Log for details"}}}}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}];

test_events(faulty_cth_exit_in_init) ->
    [{?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{empty_cth,init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}];

test_events(faulty_cth_exit_in_id) ->
    [{?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{empty_cth,id,[[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {negative, {?eh,tc_start,'_'},
      {?eh,test_done,{'DEF','STOP_TIME'}}},
     {?eh,stop_logging,[]}];

test_events(scope_per_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_per_suite_cth_SUITE,init_per_suite}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_scope_per_suite_cth_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_scope_per_suite_cth_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_scope_per_suite_cth_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
     {?eh,tc_done,{ct_scope_per_suite_cth_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_scope_per_suite_cth_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,
	       [ct_scope_per_suite_cth_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_scope_per_suite_cth_SUITE,'$proplist','_',[]]}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,tc_done,{ct_scope_per_suite_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(scope_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_suite_cth_SUITE,init_per_suite}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_scope_suite_cth_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_scope_suite_cth_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_scope_suite_cth_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_scope_suite_cth_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
     {?eh,tc_done,{ct_scope_suite_cth_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_scope_suite_cth_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_scope_suite_cth_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_scope_suite_cth_SUITE,'$proplist','_',[]]}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,tc_done,{ct_scope_suite_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(scope_per_group_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_per_group_cth_SUITE,init_per_suite}},
     {?eh,tc_done,{ct_scope_per_group_cth_SUITE,init_per_suite,ok}},

     [{?eh,tc_start,{ct_scope_per_group_cth_SUITE,{init_per_group,group1,[]}}},
      {?eh,cth,{'_',id,[[]]}},
      {?eh,cth,{'_',init,['_',[]]}},
      {?eh,cth,{'_',post_init_per_group,[group1,'$proplist','$proplist',[]]}},
      {?eh,tc_done,{ct_scope_per_group_cth_SUITE,{init_per_group,group1,[]},ok}},
      
      {?eh,tc_start,{ct_scope_per_group_cth_SUITE,test_case}},
      {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
      {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
      {?eh,tc_done,{ct_scope_per_group_cth_SUITE,test_case,ok}},
      
      {?eh,tc_start,{ct_scope_per_group_cth_SUITE,{end_per_group,group1,[]}}},
      {?eh,cth,{'_',pre_end_per_group,[group1,'$proplist',[]]}},
      {?eh,cth,{'_',post_end_per_group,[group1,'$proplist','_',[]]}},
      {?eh,cth,{'_',terminate,[[]]}},
      {?eh,tc_done,{ct_scope_per_group_cth_SUITE,{end_per_group,group1,[]},ok}}],
     
     {?eh,tc_start,{ct_scope_per_group_cth_SUITE,end_per_suite}},
     {?eh,tc_done,{ct_scope_per_group_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(scope_per_suite_state_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_per_suite_state_cth_SUITE,init_per_suite}},
     {?eh,cth,{'_',id,[[test]]}},
     {?eh,cth,{'_',init,['_',[test]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_scope_per_suite_state_cth_SUITE,'$proplist','$proplist',[test]]}},
     {?eh,tc_done,{ct_scope_per_suite_state_cth_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_scope_per_suite_state_cth_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[test]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[test]]}},
     {?eh,tc_done,{ct_scope_per_suite_state_cth_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_scope_per_suite_state_cth_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,
	       [ct_scope_per_suite_state_cth_SUITE,'$proplist',[test]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_scope_per_suite_state_cth_SUITE,'$proplist','_',[test]]}},
     {?eh,cth,{'_',terminate,[[test]]}},
     {?eh,tc_done,{ct_scope_per_suite_state_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(scope_suite_state_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_suite_state_cth_SUITE,init_per_suite}},
     {?eh,cth,{'_',id,[[test]]}},
     {?eh,cth,{'_',init,['_',[test]]}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_scope_suite_state_cth_SUITE,'$proplist',[test]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_scope_suite_state_cth_SUITE,'$proplist','$proplist',[test]]}},
     {?eh,tc_done,{ct_scope_suite_state_cth_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_scope_suite_state_cth_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[test]]}},
     {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[test]]}},
     {?eh,tc_done,{ct_scope_suite_state_cth_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_scope_suite_state_cth_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_scope_suite_state_cth_SUITE,'$proplist',[test]]}},
     {?eh,cth,{'_',post_end_per_suite,[ct_scope_suite_state_cth_SUITE,'$proplist','_',[test]]}},
     {?eh,cth,{'_',terminate,[[test]]}},
     {?eh,tc_done,{ct_scope_suite_state_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(scope_per_group_state_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_scope_per_group_state_cth_SUITE,init_per_suite}},
     {?eh,tc_done,{ct_scope_per_group_state_cth_SUITE,init_per_suite,ok}},

     [{?eh,tc_start,{ct_scope_per_group_state_cth_SUITE,{init_per_group,group1,[]}}},
      {?eh,cth,{'_',id,[[test]]}},
      {?eh,cth,{'_',init,['_',[test]]}},
      {?eh,cth,{'_',post_init_per_group,[group1,'$proplist','$proplist',[test]]}},
      {?eh,tc_done,{ct_scope_per_group_state_cth_SUITE,{init_per_group,group1,[]},ok}},
      
      {?eh,tc_start,{ct_scope_per_group_state_cth_SUITE,test_case}},
      {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[test]]}},
      {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[test]]}},
      {?eh,tc_done,{ct_scope_per_group_state_cth_SUITE,test_case,ok}},
      
      {?eh,tc_start,{ct_scope_per_group_state_cth_SUITE,{end_per_group,group1,[]}}},
      {?eh,cth,{'_',pre_end_per_group,[group1,'$proplist',[test]]}},
      {?eh,cth,{'_',post_end_per_group,[group1,'$proplist','_',[test]]}},
      {?eh,cth,{'_',terminate,[[test]]}},
      {?eh,tc_done,{ct_scope_per_group_state_cth_SUITE,{end_per_group,group1,[]},ok}}],
     
     {?eh,tc_start,{ct_scope_per_group_state_cth_SUITE,end_per_suite}},
     {?eh,tc_done,{ct_scope_per_group_state_cth_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ];

test_events(fail_pre_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},

     
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist',
					{fail,"Test failure"},[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,
                   {failed, {error,"Test failure"}}}},
     {?eh,cth,{'_',on_tc_fail,
	       [init_per_suite,{failed,"Test failure"},[]]}},

     
     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,test_case,
                        {failed,{ct_cth_empty_SUITE,init_per_suite,
				 {failed,"Test failure"}}}}},
     {?eh,cth,{'_',on_tc_skip,
	       [test_case, {tc_auto_skip,
			    {failed, {ct_cth_empty_SUITE, init_per_suite,
				     {failed, "Test failure"}}}},[]]}},

     
     {?eh,tc_auto_skip, {ct_cth_empty_SUITE, end_per_suite,
                         {failed, {ct_cth_empty_SUITE, init_per_suite,
				   {failed, "Test failure"}}}}},
     {?eh,cth,{'_',on_tc_skip,
	       [end_per_suite, {tc_auto_skip,
				{failed, {ct_cth_empty_SUITE, init_per_suite,
					  {failed, "Test failure"}}}},[]]}},

     
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth, {'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(fail_post_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,
		   {failed,{error,"Test failure"}}}},
     {?eh,cth,{'_',on_tc_fail,[init_per_suite, {failed,"Test failure"}, []]}},

     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,test_case,
                        {failed,{ct_cth_empty_SUITE,init_per_suite,
				 {failed,"Test failure"}}}}},
     {?eh,cth,{'_',on_tc_skip,[test_case,{tc_auto_skip,'_'},[]]}},
     
     {?eh,tc_auto_skip, {ct_cth_empty_SUITE, end_per_suite,
                         {failed, {ct_cth_empty_SUITE, init_per_suite,
				   {failed, "Test failure"}}}}},
     {?eh,cth,{'_',on_tc_skip,[end_per_suite,{tc_auto_skip,'_'},[]]}},

     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth, {'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(skip_pre_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist',{skip,"Test skip"},[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,{skipped,"Test skip"}}},
     {?eh,cth,{'_',on_tc_skip,
	       [init_per_suite,{tc_user_skip,{skipped,"Test skip"}},[]]}},

     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,test_case,"Test skip"}},
     {?eh,cth,{'_',on_tc_skip,[test_case,{tc_auto_skip,"Test skip"},[]]}},
     
     {?eh,tc_auto_skip, {ct_cth_empty_SUITE, end_per_suite,"Test skip"}},
     {?eh,cth,{'_',on_tc_skip,[end_per_suite,{tc_auto_skip,"Test skip"},[]]}},

     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth, {'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(skip_post_suite_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {?eh,cth,{'_',post_init_per_suite,[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,{skipped,"Test skip"}}},
     {?eh,cth,{'_',on_tc_skip,
	       [init_per_suite,{tc_user_skip,{skipped,"Test skip"}},[]]}},

     {?eh,tc_auto_skip,{ct_cth_empty_SUITE,test_case,"Test skip"}},
     {?eh,cth,{'_',on_tc_skip,[test_case,{tc_auto_skip,"Test skip"},[]]}},
     
     {?eh,tc_auto_skip, {ct_cth_empty_SUITE, end_per_suite,"Test skip"}},
     {?eh,cth,{'_',on_tc_skip,[end_per_suite,{tc_auto_skip,"Test skip"},[]]}},
     
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(recover_post_suite_cth) ->
    Suite = ct_cth_fail_per_suite_SUITE,
    [
     {?eh,start_logging,'_'},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{Suite,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[Suite,'$proplist','$proplist']}},
     {?eh,cth,{'_',post_init_per_suite,[Suite,contains([tc_status]),
					{'EXIT',{'_','_'}},[]]}},
     {?eh,tc_done,{Suite,init_per_suite,ok}},

     {?eh,tc_start,{Suite,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,
	       [test_case, not_contains([tc_status]),[]]}},
     {?eh,cth,{'_',post_end_per_testcase,
	       [test_case, contains([tc_status]),'_',[]]}},
     {?eh,tc_done,{Suite,test_case,ok}},
     
     {?eh,tc_start,{Suite,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,
	       [Suite,not_contains([tc_status]),[]]}},
     {?eh,cth,{'_',post_end_per_suite,
	       [Suite,not_contains([tc_status]),'_',[]]}},
     {?eh,tc_done,{Suite,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(update_config_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     
     {?eh,tc_start,{ct_update_config_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,
	       [ct_update_config_SUITE,contains([]),[]]}},
     {?eh,cth,{'_',post_init_per_suite,
	       [ct_update_config_SUITE,
		'$proplist',
		contains(
			  [init_per_suite,
			   pre_init_per_suite]),
		[]]}},
     {?eh,tc_done,{ct_update_config_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_update_config_SUITE, {init_per_group,group1,[]}}},
     {?eh,cth,{'_',pre_init_per_group,
	       [group1,contains(
			 [post_init_per_suite,
			  init_per_suite,
			  pre_init_per_suite]),
		[]]}},
     {?eh,cth,{'_',post_init_per_group,
	       [group1,
		contains(
		  [post_init_per_suite,
		   init_per_suite,
		   pre_init_per_suite]),
		contains(
		  [init_per_group,
		   pre_init_per_group,
		   post_init_per_suite,
		   init_per_suite,
		   pre_init_per_suite]),
	       []]}},
     {?eh,tc_done,{ct_update_config_SUITE,{init_per_group,group1,[]},ok}},

     {?eh,tc_start,{ct_update_config_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,
	       [test_case,contains(
			    [post_init_per_group,
			     init_per_group,
			     pre_init_per_group,
			     post_init_per_suite,
			     init_per_suite,
			     pre_init_per_suite]),
		[]]}},
     {?eh,cth,{'_',post_end_per_testcase,
	       [test_case,contains(
			    [init_per_testcase,
			     pre_init_per_testcase,
			     post_init_per_group,
			     init_per_group,
			     pre_init_per_group,
			     post_init_per_suite,
			     init_per_suite,
			     pre_init_per_suite]),
		ok,[]]}},
     {?eh,tc_done,{ct_update_config_SUITE,test_case,ok}},

     {?eh,tc_start,{ct_update_config_SUITE, {end_per_group,group1,[]}}},
     {?eh,cth,{'_',pre_end_per_group,
	       [group1,contains(
			 [post_init_per_group,
			  init_per_group,
			  pre_init_per_group,
			  post_init_per_suite,
			  init_per_suite,
			  pre_init_per_suite]),
		[]]}},
     {?eh,cth,{'_',post_end_per_group,
	       [group1,
		contains(
		  [pre_end_per_group,
		   post_init_per_group,
		   init_per_group,
		   pre_init_per_group,
		   post_init_per_suite,
		   init_per_suite,
		   pre_init_per_suite]),
	       ok,[]]}},
     {?eh,tc_done,{ct_update_config_SUITE,{end_per_group,group1,[]},ok}},
     
     {?eh,tc_start,{ct_update_config_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,
	       [ct_update_config_SUITE,contains(
					 [post_init_per_suite,
					  init_per_suite,
					  pre_init_per_suite]),
		[]]}},
     {?eh,cth,{'_',post_end_per_suite,
	       [ct_update_config_SUITE,contains(
					 [pre_end_per_suite,
					  post_init_per_suite,
					  init_per_suite,
					  pre_init_per_suite]),
	       '_',[]]}},
     {?eh,tc_done,{ct_update_config_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[contains(
				[post_end_per_suite,
				 pre_end_per_suite,
				 post_init_per_suite,
				 init_per_suite,
				 pre_init_per_suite])]}},
     {?eh,stop_logging,[]}
    ];

test_events(state_update_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{'_',init_per_suite}},
     
     {?eh,tc_done,{'_',end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[contains(
				[post_end_per_suite,pre_end_per_suite,
				 post_end_per_group,pre_end_per_group,
				 {not_in_order,
				  [post_end_per_testcase,pre_init_per_testcase,
				   on_tc_skip,post_end_per_testcase,
				   pre_init_per_testcase,on_tc_fail,
				   post_end_per_testcase,pre_init_per_testcase]
				 },
				 post_init_per_group,pre_init_per_group,
				 post_init_per_suite,pre_init_per_suite,
				 init])]}},
     {?eh,cth,{'_',terminate,[contains(
				[post_end_per_suite,pre_end_per_suite,
				 post_end_per_group,pre_end_per_group,
				 {not_in_order,
				  [post_end_per_testcase,pre_init_per_testcase,
				   on_tc_skip,post_end_per_testcase,
				   pre_init_per_testcase,on_tc_fail,
				   post_end_per_testcase,pre_init_per_testcase]
				 },
				 post_init_per_group,pre_init_per_group,
				 post_init_per_suite,pre_init_per_suite,
				 init]
			       )]}},
     {?eh,stop_logging,[]}
    ];

test_events(options_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{empty_cth,init,['_',[test]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{empty_cth,pre_init_per_suite,
	       [ct_cth_empty_SUITE,'$proplist',[test]]}},
     {?eh,cth,{empty_cth,post_init_per_suite,
	       [ct_cth_empty_SUITE,'$proplist','$proplist',[test]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,cth,{empty_cth,pre_init_per_testcase,[test_case,'$proplist',[test]]}},
     {?eh,cth,{empty_cth,post_end_per_testcase,[test_case,'$proplist','_',[test]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,cth,{empty_cth,pre_end_per_suite,
	       [ct_cth_empty_SUITE,'$proplist',[test]]}},
     {?eh,cth,{empty_cth,post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[test]]}},
     {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{empty_cth,terminate,[[test]]}},
     {?eh,stop_logging,[]}
    ];

test_events(same_id_cth) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,cth,{'_',init,[same_id_cth,[]]}},
     {?eh,cth,{'_',id,[[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{ct_cth_empty_SUITE,init_per_suite}},
     {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {negative,
       {?eh,cth,{'_',pre_init_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
      {?eh,cth,{'_',post_init_per_suite,
		[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}}},
     {negative,
      {?eh,cth,{'_',post_init_per_suite,
		[ct_cth_empty_SUITE,'$proplist','$proplist',[]]}},
      {?eh,tc_done,{ct_cth_empty_SUITE,init_per_suite,ok}}},

     {?eh,tc_start,{ct_cth_empty_SUITE,test_case}},
     {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
     {negative,
      {?eh,cth,{'_',pre_init_per_testcase,[test_case,'$proplist',[]]}},
      {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}}},
     {negative,
      {?eh,cth,{'_',post_end_per_testcase,[test_case,'$proplist',ok,[]]}},
      {?eh,tc_done,{ct_cth_empty_SUITE,test_case,ok}}},
     
     {?eh,tc_start,{ct_cth_empty_SUITE,end_per_suite}},
     {?eh,cth,{'_',pre_end_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
     {negative,
      {?eh,cth,{'_',pre_end_per_suite,[ct_cth_empty_SUITE,'$proplist',[]]}},
      {?eh,cth,{'_',post_end_per_suite,[ct_cth_empty_SUITE,'$proplist','_',[]]}}},
     {negative,
      {?eh,cth,{'_',post_end_per_suite,
		[ct_cth_empty_SUITE,'$proplist','_',[]]}},
      {?eh,tc_done,{ct_cth_empty_SUITE,end_per_suite,ok}}},
     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(fail_n_skip_with_minimal_cth) ->
    [{?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,cth,{'_',init,['_',[]]}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,tc_start,{'_',init_per_suite}},
     
     {?eh,tc_done,{'_',end_per_suite,ok}},
     {?eh,cth,{'_',terminate,[[]]}},
     {?eh,stop_logging,[]}
    ];

test_events(ok) ->
    ok.


%% test events help functions
contains(List) ->
    fun(Proplist) when is_list(Proplist) ->
	    contains(List,Proplist)
    end.

contains([{not_in_order,List}|T],Rest) ->
    contains_parallel(List,Rest),
    contains(T,Rest);
contains([{Ele,Pos}|T] = L,[H|T2]) ->
    case element(Pos,H) of
	Ele ->
	    contains(T,T2);
	_ ->
	    contains(L,T2)
    end;
contains([Ele|T],[{Ele,_}|T2])->
    contains(T,T2);
contains([Ele|T],[Ele|T2])->
    contains(T,T2);
contains(List,[_|T]) ->
    contains(List,T);
contains([],_) ->
    match.

contains_parallel([Key | T], Elems) ->
    contains([Key],Elems),
    contains_parallel(T,Elems);
contains_parallel([],_Elems) ->
    match.

not_contains(List) ->
    fun(Proplist) when is_list(Proplist) ->
	    [] = [Ele || {Ele,_} <- Proplist,
			 Test <- List,
			 Test =:= Ele]
    end.
