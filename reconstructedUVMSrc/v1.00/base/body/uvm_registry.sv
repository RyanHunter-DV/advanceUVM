`include "uvm_registry.svh"

`define func(r,fn) function r uvm_component_registry::fn
`define endf endfunction

`func(T,create_component) (string name, uvm_component parent); // {


`endf // }



`undef func
`undef endf
