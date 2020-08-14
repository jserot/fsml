(** Types *)

type t =
  | TyInt of t * size (** [t] is for signness *)
  | TyBool
  | TyArrow of t * t  (** Internal use only *)
  | TyProduct of t list  (** Internal use only *)
  | TyVar of t var  (** Internal use only *)
  | TySigned    (** Phantom type *)
  | TyUnsigned  (** Phantom type *)
  [@@deriving show {with_path=false}, yojson]

and size =
  | SzConst of int
  | SzVar of size var
  [@@deriving show {with_path=false}, yojson]

and 'a var =
  { stamp: string;
    mutable value: 'a value }
  [@@deriving show {with_path=false}, yojson]

and 'a value =
  | Unknown
  | Known of 'a
  [@@deriving show {with_path=false}, yojson]

type typ_scheme =
  { ts_tparams: (t var) list;
    ts_sparams: (size var) list;
    ts_body: t }
  [@@deriving show {with_path=false}, yojson]

(** {2 Builders} *)

val new_type_var: unit -> t var
  (** [new_type_var ()] returns a fresh type variable *)
  
val new_size_var: unit -> size var
  (** [new_size_var ()] returns a fresh size variable *)
  
val type_int: unit -> t
  (** [type_int ()] is [TyInt (SzVar (new_size_var ()))] *)

val trivial_scheme: t -> typ_scheme

(** {2 Unification} *)

exception TypeConflict of t * t
exception TypeCircularity of t * t

val unify: t -> t -> unit

val type_instance: typ_scheme -> t

val real_type: t -> t

exception Polymorphic of t
                       
val mono_type: t -> t
  (** Remove all type variables from type representation [t]. Raises [!Polymorphic] if 
      [t] contains unresolved type variables. *)
  
(** {2 Printing} *)
  
val to_string: t -> string
