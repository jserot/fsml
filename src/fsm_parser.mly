(* %token TYPE *)
%token NAME
%token STATES
%token INPUTS
%token OUTPUTS
%token VARS
%token TRANS
%token ITRANS
%token <int> INT
%token <bool> BOOL
%token TYBOOL
%token TYINT
%token TYUINT
%token <string> LID UID
%token SEMICOLON
%token COMMA
%token COLON
%token EQUAL
%token NOTEQUAL
%token LPAREN
%token RPAREN
%token LT
%token GT
%token LTE
%token GTE
%token PLUS MINUS TIMES DIV
(* %token LAND LOR LXOR
 * %token SHL SHR *)
(* %token BARBAR *)
%token COLEQ
%token ARROW
%token WHEN
%token WITH
%token EOF

(* Precedences and associativities for expressions *)

%left EQUAL NOTEQUAL GT LT GTE LTE
(* %left SHR SHL
 * %left LAND LOR LXOR *)
%left PLUS MINUS
%left TIMES DIV
(* %nonassoc prec_unary_minus         (\* Highest precedence *\) *)

%start <Guard.t> guard_top
%start <Guard.t list> guards_top
%start <Action.t> action_top
%start <Action.t list> actions_top
%start <Transition.t> transition_top
%start <Fsm.t> fsm
%start <Stimuli.t list> stimuli

%{
open Fsm

let mk_typed_expr e ty = let open Expr in { e_desc = e; e_typ = ty }
let mk_int_expr e = mk_typed_expr e (Types.type_int ())
let mk_bool_expr e = mk_typed_expr e Types.TyBool
let mk_expr e = mk_typed_expr e (Types.TyVar (Types.new_type_var ()))
%}

%%

%public optional(X):
    /* Nothing */ { [] }
  | x=X { x }

fsm:
  | NAME COLON name=LID SEMICOLON
    STATES COLON states=separated_nonempty_list(COMMA, UID) SEMICOLON
    INPUTS COLON inps=separated_list(COMMA, iovar) SEMICOLON
    OUTPUTS COLON outps=separated_list(COMMA, iovar) SEMICOLON
    vars = optional(vars)
    TRANS COLON trans=nonempty_list(terminated(transition, SEMICOLON))
    ITRANS COLON itrans=itransition SEMICOLON EOF {
        { id = name;
          states = states; 
          inps = inps; 
          outps = outps; 
          vars = vars; 
          trans = trans;
          itrans = itrans } }
          
vars:
  | VARS COLON vars=terminated(separated_list(COMMA, iovar),SEMICOLON) { vars }

iovar:
  | id=LID COLON ty=type_expr { id, ty }

transition:
  | src=UID ARROW dst=UID guards=guards actions=actions
      { (src, guards, actions, dst) }

guards:
  | (* Nothing *) { [] }
  | WHEN guards=separated_nonempty_list(COMMA, expr) { guards }

actions:
  | (* Nothing *) { [] }
  | WITH actions=separated_nonempty_list(COMMA, action) { actions }

action:
  | id=LID COLEQ e=expr  { Action.Assign (id,e) }

itransition:
  | ARROW dst=UID actions=actions { dst, actions }

(* EXPRESSIONS *)

expr:
  | e = simple_expr
      { e }
  (* | e1 = expr SHR e2 = expr
   *     { EBinop (">>", e1, e2) }
   * | e1 = expr SHL e2 = expr
   *     { EBinop ("<<", e1, e2) }
   * | e1 = expr LAND e2 = expr
   *     { EBinop ("&", e1, e2) }
   * | e1 = expr LOR e2 = expr
   *     { EBinop ("|", e1, e2) }
   * | e1 = expr LXOR e2 = expr
   *     { EBinop ("^", e1, e2) } *)
  | e1 = expr PLUS e2 = expr
      { mk_int_expr (EBinop ("+", e1, e2)) }
  | e1 = expr MINUS e2 = expr
      { mk_int_expr (EBinop ("-", e1, e2)) }
  | e1 = expr TIMES e2 = expr
      { mk_int_expr (EBinop ("*", e1, e2)) }
  | e1 = expr DIV e2 = expr
      { mk_int_expr (EBinop ("/", e1, e2)) }
  | e1 = expr EQUAL e2 = expr
      { mk_bool_expr (EBinop ("=", e1, e2)) }
  | e1 = expr NOTEQUAL e2 = expr
      { mk_bool_expr (EBinop ("!=", e1, e2)) }
  | e1 = expr GT e2 = expr
      { mk_bool_expr (EBinop (">", e1, e2)) }
  | e1 = expr LT e2 = expr
      { mk_bool_expr (EBinop ("<", e1, e2)) }
  | e1 = expr GTE e2 = expr
      { mk_bool_expr (EBinop (">=", e1, e2)) }
  | e1 = expr LTE e2 = expr
      { mk_bool_expr (EBinop ("<=", e1, e2)) }

simple_expr:
  | v = LID
      { mk_expr (Expr.EVar v) }
  | c = INT
      { mk_int_expr (Expr.EInt c) }
  | c = BOOL
      { mk_bool_expr (Expr.EBool c) }
  | MINUS c=INT
      { mk_int_expr (Expr.EInt (-c)) }
  | LPAREN e = expr RPAREN
      { e }

(* TYPE EXPRESSIONs *)

type_expr:
  | TYBOOL { Types.TyBool }
  | TYINT sz=int_size { Types.TyInt (Types.TySigned, sz) }
  | TYUINT sz=int_size { Types.TyInt (Types.TyUnsigned, sz) }

int_size:
  | (* Nothing *) { Types.SzVar (Types.new_size_var ()) }
  | LT sz=INT GT { Types.SzConst sz }

(* Simulation stimuli *)

value:
  | v = INT
      { Expr.Int v }
  | v = BOOL
      { Expr.Bool v }

event:
  | t=INT COMMA v=value  { (t,v) }

stimuli:
  | id=LID COLON vcs=separated_nonempty_list(SEMICOLON, event) EOF { Stimuli.changes id vcs }

(* Hooks to intermediate parsers *)

guard_top: 
  | g=expr EOF { g }

guards_top: 
  | gs=separated_list(COMMA, expr) EOF { gs }

action_top: 
  | act=action EOF { act }

actions_top: 
  | acts=separated_list(COMMA, action) EOF { acts }

transition_top: 
  | t=transition EOF { t }

