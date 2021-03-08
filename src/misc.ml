(**********************************************************************)
(*                                                                    *)
(*              This file is part of the FSML library                 *)
(*                     github.com/jserot/fsml                         *)
(*                                                                    *)
(*  Copyright (c) 2020-present, Jocelyn SEROT.  All rights reserved.  *)
(*                                                                    *)
(*  This source code is licensed under the license found in the       *)
(*  LICENSE file in the root directory of this source tree.           *)
(*                                                                    *)
(**********************************************************************)

let string_of_list ~f ~sep l =
  let rec h = function
      [] -> ""
    | [x] -> f x
    | x::xs -> f x ^ sep ^ h xs in
  h l

let iter_fst f l =
  ignore (List.fold_left (fun z x -> f z x; false) true l)

let list_make ~f ~lo ~hi =
  let rec mk i =
    if i <= hi then f i :: mk (i+1)
    else [] in
  mk lo

let list_parse ~parse_item ~sep s =
 let rec parse s =
  match Stream.peek s with
  | Some _ ->
     let e = parse_item s in
     let es = parse_aux s in
     e::es
  | None ->
     []
 and parse_aux s =
  match Stream.peek s with
  | Some (Genlex.Kwd sep') when sep=sep' ->
     Stream.junk s;
     parse s
  | _ ->
     [] in
 parse s

let string_of_opt f = function
| None -> ""
| Some x -> f x

let rec bit_size n = if n=0 then 0 else 1 + bit_size (n/2)

let rec pow2 k = if k = 0 then 1 else 2 * pow2 (k-1)

let quote_string s = "\"" ^ s ^ "\""                                             

let check_dir path = 
  if not (Sys.file_exists path && Sys.is_directory path)
  then Unix.mkdir path 0o777

let spaces n = String.make n ' '

let replace_assoc k v l =
  let rec scan = function 
    [] -> []
    | (k',v')::rest -> if k = k' then (k,v)::scan rest else (k',v')::scan rest  in
  scan l
