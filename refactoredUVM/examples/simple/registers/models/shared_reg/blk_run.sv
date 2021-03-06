// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "reg_pkg.sv"
`include "blk_pkg.sv"

program tb;

import blk_pkg::*;
import reg_pkg::*;

`include "blk_testlib.sv"

initial begin automatic uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   uvm_report_server svr;
   svr = cs_.get_report_server();
   svr.set_max_quit_count(10);
   run_test();
end

endprogram
