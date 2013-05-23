-record(geef_ref, {handle, name :: binary(), type :: atom(), target :: binary() | geef_oid()}).
-record(geef_oid, {oid}).
-record(geef_object, {type :: atom(), handle}).
-record(geef_index_entry, {mode, id :: geef_oid(), path :: iolist()}).

-type geef_ref() :: #geef_ref{}.
-type geef_oid() :: #geef_oid{}.
-type geef_object() :: #geef_object{}.
-type geef_index_entry() :: #geef_index_entry{}.
