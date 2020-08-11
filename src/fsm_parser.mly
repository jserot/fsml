(* %token TYPE *)
%token NAME
%token STATES
%token INPUTS
%token OUTPUTS
%token VARS
%token TRANS
%token ITRANS
%token <int> INT
(* %token TYBOOL
 * %token TYINT *)
%token <string> LID UID
(* %token <string> UID *)
(* %token <string> STRING *)
%token SEMICOLON
%token COMMA
(* %token DOT *)
%token COLON
%token EQUAL
%token NOTEQUAL
(* %token LBRACE
 * %token RBRACE *)
%token LPAREN
%token RPAREN
(* %token LBRACKET
 * %token RBRACKET *)
%token LT
%token GT
%token LTE
%token GTE
%token PLUS MINUS TIMES DIV (*MOD*)
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
%left PLUS MINUS (* FPLUS FMINUS *)
%left TIMES DIV (* FTIMES FDIV MOD *)   
(* %nonassoc prec_unary_minus         (\* Highest precedence *\) *)

%start <Action.t> action_top
%start <Transition.t> transition_top
(* %start <Action.t list> actions_top
 * %start <Expr.t> expr_top
 * %start <Events.t> events_top *)
%start <Events.t list> stimuli_top
%start <Fsm.t> fsm

%{
open Fsm
%}

%%

%public optional(X):
    /* Nothing */ { [] }
  | x=X { x }

(* FSM MODEL *)

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
  | id=LID { id }

(* var:
 *   (\* | ids=separated_nonempty_list(COMMA,LID) COLON ty=type_expr *\)
 *   | ids=separated_nonempty_list(COMMA,LID)
 *       { List.map (fun id -> (id, mk_type_expression ($symbolstartofs,$endofs) ty)) ids } *)

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

(* TYPE EXPRESSIONs *)

(* type_expr:
 *   | TYINT a=int_annot { mk_type_expr (Type_expr.TEInt a) }
 *   | TYBOOL { mk_type_expr (Type_expr.TEBool) }
 * 
 * int_annot:
 *     | (\* Nothing *\)
 *       { TA_none }
 *     | LT sz=type_index_expr GT
 *         { TA_size sz }
 *     | LT lo=type_index_expr COLON hi=type_index_expr GT
 *         { TA_range (lo, hi) } *)

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
      { EBinop ("+", e1, e2) }
  | e1 = expr MINUS e2 = expr
      { EBinop ("-", e1, e2) }
  | e1 = expr TIMES e2 = expr
      { EBinop ("*", e1, e2) }
  | e1 = expr DIV e2 = expr
      { EBinop ("/", e1, e2) }
  (* | e1 = expr MOD e2 = expr
   *     { EBinop ("mod", e1, e2) } *)
  | e1 = expr EQUAL e2 = expr
      { ERelop ("=", e1, e2) }
  | e1 = expr NOTEQUAL e2 = expr
      { ERelop ("!=", e1, e2) }
  | e1 = expr GT e2 = expr
      { ERelop (">", e1, e2) }
  | e1 = expr LT e2 = expr
      { ERelop ("<", e1, e2) }
  | e1 = expr GTE e2 = expr
      { ERelop (">=", e1, e2) }
  | e1 = expr LTE e2 = expr
      { ERelop ("<=", e1, e2) }

simple_expr:
  | v = LID
      { Expr.EVar v }
  | c = INT
      { Expr.EInt c }
  | MINUS c=INT { Expr.EInt (-c) }
  | LPAREN e = expr RPAREN
      { e }

(* Event sets *)

events:
  | TIMES { [] }
  | events=separated_nonempty_list(COMMA, action) { events }

(* Aux parsers *)

(* expr_top: 
 *   | e=expr EOF { e } *)

(* actions_top: 
 *   | actions=separated_nonempty_list(COMMA, action) EOF { actions }
 *)

transition_top: 
  | t=transition EOF { t }

action_top: 
  | a=action EOF { a }

(* events_top:
 *   | events=separated_nonempty_list(COMMA, action) EOF { events } *)

stimuli_top:
  | stimuli=separated_nonempty_list(SEMICOLON, events) EOF { stimuli }

