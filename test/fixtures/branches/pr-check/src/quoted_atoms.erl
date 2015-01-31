%%%-------------------------------------------------------------------
%%% @author Grigory Starinkin
%%%-------------------------------------------------------------------
-module(quoted_atoms).

-behaviour('gen_server').

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3]).

-export([my_function/0]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({'local', ?SERVER}, ?MODULE, [], []).

handle_call(_Request, _From, State) ->
    Reply = ok,
    State = {'The',
             q_u_i_c_k,
             br@wn,             
             '4x',
             juMps,
             ov3r,
             the,
             'Lazy',
             'dog',
             'the',
             q_u_i_c_k1br@wnfox,
             'JuMps',
             ov3r_The_la7Y,
             'd@g',
             'andalso',
             'band',
             'case'},
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply,   State}.

good_function() ->
    [look, all, atoms, are, correct].

bad_function() ->
    ['that', 'is', a, bad_function].

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason,  _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {'ok', State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
my_function()   ->
    MyList = lists:seq(1, 10),
    [
        begin
            It * 10
        end
        || It <- MyList
    ].
