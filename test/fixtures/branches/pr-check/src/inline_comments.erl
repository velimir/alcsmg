%%%-------------------------------------------------------------------
%%% @author Grigory Starinkin
%%% @copyright (C) 2014, Grigory Starinkin
%%% Created : 14 May 2014 by Grigory Starinkin
%%%-------------------------------------------------------------------
-module(inline_comments).

%% Include files

%% API
-export([]).

%% Corba callbacks
-export([init/1, terminate/2, code_change/3]).

-record(state, {}).

%%%===================================================================
%%% Corba callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    %% return standard empty result
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Shutdown the server
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.
    %% ok?

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok,
     %% comment tuples
     State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% get_flow_blocks documentation
%%--------------------------------------------------------------------
get_flow_blocks(
  %% comment on the first argument
  [],
  %% comment on the second argument
  {[], Closed}) ->
    %% reverse to get proper order
    lists:reverse(Closed);
get_flow_blocks([], {Opened, _Closed})
  %% comment on guard
  when is_everyone_happy()
       andalso
       %% comment on guard 2
       is_everyone_healthy() ->
    %% Comment of error log
    alcs_log:error("Unclosed definition: ~w", [hd(Opened)]),
    %% throw an error if
    %% encountered unclosed flow derective
    throw(unclosed_def);
%% just another functional clause
get_flow_blocks([Attr | Attributes], {Opened, Closed} = Defs) ->
    %% getting Attribute name
    case get_attr_name(Attr) of
        Name when Name == ifdef; Name == ifndef ->
            {L, _} = erl_syntax:get_pos(Attr),
            get_flow_blocks(Attributes, {[{L, undefined} | Opened], Closed});
        else ->
            {ElseLocation, _} = erl_syntax:get_pos(Attr),
            case Opened of
                [{OpenLoc, undefined} | OpenTail] ->
                    Closed2 = [{OpenLoc, ElseLocation} | Closed],
                    Opened2 = [{ElseLocation, undefined} | OpenTail],
                    get_flow_blocks(Attributes, {Opened2, Closed2});
                _ ->
                    alcs_log:error("Mismatched definitions at: ~w", [Attr]),
                    %% throw an error whether there wasn't unclosed flow def
                    throw(mismatched_def)
            end;
        endif ->
            {EndLocation, _} = erl_syntax:get_pos(Attr),
            case Opened of
                [{OpenLoc, undefined} | OpenTail] ->
                    Closed2 = [{OpenLoc, EndLocation} | Closed],
                    %% make another call
                    get_flow_blocks(Attributes, {OpenTail, Closed2});
                _ ->
                    alcs_log:error("Mismatched definitions at: ~w", [Attr]),
                    throw(mismatched_def)
            end;
        _ ->
            get_flow_blocks(Attributes, Defs)
    end.

my_cool_function() ->
    %% OMFG, it's an inline comment
    lists:foreach(
        fun (It) ->
            io:format("Just show it to the whole world: ~p", [It])
        end,
        [
            'this atom is ok',
            'but_not_this',
            another_ok_atom
        ]
	    %%<- Here's a \t
    ).

%% ===================================================================
%% EUnit tests
%% ===================================================================
-ifdef(TEST).
%% Some comment

test_server_test_() ->
    %% comment
    {foreach,
     fun() -> ok end,
     fun(_Config) -> ok %% return ok
     end,
     {"lol",
      begin
          %% check that true is true
          ?assert(
             %% it should definetelly pass the test
             true
             %% it's true anyway
            )
      end
     }
    }.

-endif.
%% commend at the end of the file
