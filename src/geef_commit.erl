-module(geef_commit).
-export([tree_id/1, tree/1, lookup/2]).
-export([create/5, create/6, create/7]).
-export([message/1, author/1, committer/1]).
-export([parent_count/1, parent_id/2]).

-include("geef_records.hrl").

-type commit() :: geef_obj:object(commit).
-export_type([commit/0]).

-spec tree_id(commit()) -> geef_oid:oid().
tree_id(#geef_object{type=commit,handle=Handle}) ->
    geef_nif:commit_tree_id(Handle).

-spec tree(commit()) -> {ok, geef_tree:tree()} | {error, term()}.
tree(#geef_object{type=commit,handle=Handle}) ->
    case geef_nif:commit_tree(Handle) of
	{ok, Id, Handle} ->
	    {ok, #geef_object{id=Id, handle=Handle}};
	Other ->
	    Other
    end.

-spec lookup(pid(), geef_oid:oid()) -> {ok, commit()} | {error, term()}.
lookup(Repo, Id) ->
    geef_obj:lookup(Repo, Id, commit).


%% Full version, accepts all paremeters
-spec create(pid(), iolist(), geef_sig:signature(), geef_sig:signature(),
	     iolist(), iolist(), geef_oid:oid(), [geef_oid:oid()]) -> {ok, geef_oid:oid()} | {error, term()}.
create(Repo, Ref, Author = #geef_signature{}, Committer = #geef_signature{}, Encoding, Message, Tree, Parents)
  when is_list(Parents) ->
    Handle = geef_repo:handle(Repo),
    geef_nif:commit_create(Handle, Ref, Author, Committer, Encoding, Message, Tree, Parents).

% Common version, accepts ref and encoding as options
-spec create(pid(), geef_sig:signature(), geef_sig:signature(), iolist(), geef_oid:oid(), [geef_oid:oid()],
	     [proplists:property()]) -> {ok, geef_oid:oid()} | {error, term()}.
create(Repo, Author = #geef_signature{}, Committer = #geef_signature{}, Message, Tree, Parents, Opts) ->
    Ref = proplists:get_value(update_ref, Opts, undefined),
    Encoding = proplists:get_value(encoding, Opts, undefined),
    create(Repo, Ref, Author, Committer, Encoding, Message, Tree, Parents).

-spec create(pid(), geef_sig:signature(), geef_sig:signature(), iolist(), geef_oid:oid(), [geef_oid:oid()])
	    -> {ok, geef_oid:oid()} | {error, term()}.
create(Repo, Author = #geef_signature{}, Committer = #geef_signature{}, Message, Tree, Parents) ->
    create(Repo, Author, Committer, Message, Tree, Parents, []);

% Version with both the same
%% @doc Create a new commit. Person will be used for both author and committer.
create(Repo, Person = #geef_signature{}, Message, Tree, Parents, Opts) ->
    create(Repo, Person, Person, Message, Tree, Parents, Opts).

create(Repo, Person = #geef_signature{}, Message, Tree, Parents) ->
    create(Repo, Person, Person, Message, Tree, Parents, []).

-spec message(commit()) -> {ok, binary()} | {error, term()}.
message(#geef_object{type=commit,handle=Handle}) ->
    geef_nif:commit_message(Handle).

-spec author(commit()) -> {ok, geef_sig:signature()} | {error, term()}.
author(#geef_object{type=commit,handle=Handle}) ->
    case geef_nif:commit_author(Handle) of
        {ok, Name, Email, Timestamp, Offset} ->
            {ok, geef_sig:convert(Name, Email, Timestamp, Offset)};
        Err = {error, _} ->
            Err
    end.

-spec committer(commit()) -> {ok, geef_sig:signature()} | {error, term()}.
committer(#geef_object{type=commit,handle=Handle}) ->
    case geef_nif:commit_committer(Handle) of
        {ok, Name, Email, Timestamp, Offset} ->
            {ok, geef_sig:convert(Name, Email, Timestamp, Offset)};
        Err = {error, _} ->
            Err
    end.

-spec parent_count(commit()) -> {ok, pos_integer()} | {error, term()}.
parent_count(#geef_object{type=commit,handle=Handle}) ->
    geef_nif:commit_parent_count(Handle).

-spec parent_id(commit(), non_neg_integer()) -> {ok, geef_oid:oid()} | {error, term()}.
parent_id(#geef_object{type=commit,handle=Handle}, Nth) ->
    geef_nif:commit_parent_id(Handle, Nth).
