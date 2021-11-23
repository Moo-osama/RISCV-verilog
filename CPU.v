`timescale 1ns / 1ps
`include "defines.v"


module CPU(
    input clk,
    input rst
    );
    
    wire [31:0]PC_input;
    wire [31:0]PC_output;
    wire [31:0]PC_plus_4;
    wire [31:0]JAL_JALR_addr;
    wire [31:0]ALU_or_mem_out;
    wire [31:0]RF_write_data;
    wire [1:0] forward_A; 
    wire [1:0] forward_B; 
    wire [31:0] ALU_input_1; 
    wire [31:0] ALU_input_2; 
    wire [15:0] mem_input_addr; 
    reg finalStall, prevStall; 
    wire [31:0] IF_ID_out_PC, IF_ID_out_PC_plus_4, IF_ID_out_inst;
    wire [31:0] ID_EX_out_PC, ID_EX_out_PC4, ID_EX_out_readData1, ID_EX_out_readData2, ID_EX_out_imm;
    wire [10:0] ID_EX_out_controls;
    wire [2:0] ID_EX_out_funct3;
    wire [4:0] ID_EX_out_rs1, ID_EX_out_rs2, ID_EX_out_rd, ID_EX_out_opcode;
    wire ID_EX_out_inst_30, ID_EX_out_inst_25;
    wire [31:0] pc_plus_imm, EX_MEM_out_ALUOut, EX_MEM_out_PC_plus_4, EX_MEM_out_readData2, EX_MEM_out_PC_plus_imm;
    wire [6:0] EX_MEM_out_controls;
    wire [4:0] EX_MEM_out_rd, EX_MEM_out_rs1, EX_MEM_out_rs2, EX_MEM_out_opcode;
    wire [3:0] EX_MEM_out_flags;
    wire [2:0] EX_MEM_out_funct3;
    wire [31:0] MEM_WB_out_memOUT, MEM_WB_out_ALUOut, MEM_WB_out_PC_plus_4;
    wire [2:0] MEM_WB_out_controls;
    wire [4:0] MEM_WB_out_rd;
    wire mem_addr_sig; 
    reg final_load_PC;
    reg [2:0] WB_controls;
    reg [31:0] instruction;
    reg IF_ID_out_stall;
    reg [10:0] controls;
    reg [6:0] MEM_controls;
    wire useless_carry, carry_on_load, stall, stallSructural; 
    wire [31:0]memory_output; 
    wire [31:0] finalDecInst; 
    wire branch_taken;
    wire branch_inst;
    wire memRead;
    wire memToReg;
    wire [1:0]ALUOp;
    wire memWrite;
    wire ALU_input_2_sig;
    wire ALU_input_1_sig;                       
    wire regWrite;
    wire JALR_sig;                         
    wire RF_write_data_sel;                  
    wire carry_flag;
    wire zero_flag;
    wire ov_flag;
    wire N_flag;
    wire [3:0]ALU_signal;
    wire [31:0]ALU_result;
    wire [31:0]readData1;
    wire [31:0]readData2;
    wire [31:0]imm;
    wire [31:0]ALU_4x1_mux_out_1;
    wire [31:0]ALU_4x1_mux_out_2;
    
    
    always @ (*)
    begin
        WB_controls = EX_MEM_out_controls[2:0];
        
        if (stall | stallSructural)
            final_load_PC = 0;
        else
            final_load_PC = carry_on_load;
            
        if (branch_taken | stallSructural | stall)
            instruction = `nop;
        else
            instruction = memory_output;
            
        if (carry_on_load == 0)
            IF_ID_out_stall = 0;
        else
            IF_ID_out_stall = ~stall;
     
        if (branch_taken | stall)
            controls = 0;
        else
            controls = {ALUOp, ALU_input_2_sig, ALU_input_1_sig, branch_inst, 
                        memRead, memWrite, JALR_sig, memToReg, regWrite, 
                        RF_write_data_sel};
        
        if (branch_taken)
            MEM_controls = 0;
        else
            MEM_controls = ID_EX_out_controls[6:0];    
     
    end
    
    assign mem_addr_sig = (clk == 0)? EX_MEM_out_controls[5]:(EX_MEM_out_controls[4])? 1:EX_MEM_out_controls[5];
    
    
    adder PC_plus_4_adder(
        (PC_output), 
        (4),
        (0),
        (useless_carry),
        (PC_plus_4)
        );
    
    register PC(
        (clk),
        (rst),
        (final_load_PC), 
        (PC_input),
        (PC_output)
        );
    
    mux_2x1 mem_addr_mux( 
        ({16'b0, PC_output[15:0]}),
        ({16'b0, EX_MEM_out_ALUOut[15:0]}),
        (mem_addr_sig),
        (mem_input_addr)
        ); 
        
    inst_data_mem inst_data_memm( 
        (clk),
        (EX_MEM_out_controls[5]),
        (EX_MEM_out_controls[4]),
        (EX_MEM_out_funct3),
        (mem_input_addr),
        (EX_MEM_out_readData2),
        (memory_output)
        ); 
    
    register #(96) IF_ID(
        (clk),
        (rst),
        (IF_ID_out_stall), 
        ({
            PC_output, 
            PC_plus_4, 
            instruction
        }), 
        ({
            IF_ID_out_PC, 
            IF_ID_out_PC_plus_4, 
            IF_ID_out_inst
        }) 
        );
        
    register_file reg_filee(
        (clk),
        (rst),
        (MEM_WB_out_controls[1]),
        (IF_ID_out_inst[`IR_rs1]),
        (IF_ID_out_inst[`IR_rs2]),
        (MEM_WB_out_rd),
        (RF_write_data),
        (readData1),
        (readData2)
        );
        
    control_unit control_unitt(
        ({IF_ID_out_inst[6:0]}),
        (IF_ID_out_inst[20]),
        (branch_inst),
        (memRead),
        (memToReg),
        (ALUOp),
        (memWrite),
        (ALU_input_2_sig),
        (ALU_input_1_sig), 
        (regWrite),
        (JALR_sig), 
        (RF_write_data_sel), 
        (carry_on_load)
        );
        
    ImmGen immGen(
        (IF_ID_out_inst),
        (imm)
        );
    
    register #(196) ID_EX(
        (clk),
        (rst),
        (carry_on_load), 
        ({
            controls, 
            IF_ID_out_PC, 
            IF_ID_out_PC_plus_4, 
            readData1, 
            readData2,
            imm, 
            IF_ID_out_inst[`IR_funct3], 
            IF_ID_out_inst[`IR_rs1], 
            IF_ID_out_inst[`IR_rs2], 
            IF_ID_out_inst[`IR_rd], 
            IF_ID_out_inst[30], 
            IF_ID_out_inst[25], 
            IF_ID_out_inst[`IR_opcode]
        }), 
        ({
            ID_EX_out_controls, 
            ID_EX_out_PC, 
            ID_EX_out_PC4, 
            ID_EX_out_readData1, 
            ID_EX_out_readData2,
            ID_EX_out_imm, 
            ID_EX_out_funct3, 
            ID_EX_out_rs1, 
            ID_EX_out_rs2, 
            ID_EX_out_rd, 
            ID_EX_out_inst_30, 
            ID_EX_out_inst_25, 
            ID_EX_out_opcode
        }) 
        ); 
    
    adder PC_plus_imm_adder(
        (ID_EX_out_PC), 
        (ID_EX_out_imm),
        (0),
        (useless_carry),
        (pc_plus_imm)
        );
    
    forwarding_unit forwarding_unitt(   
         (ID_EX_out_rs1),
         (ID_EX_out_rs2),
         (EX_MEM_out_rd),
         (MEM_WB_out_rd),
         (EX_MEM_out_controls[1]),
         (MEM_WB_out_controls[1]),
         (forward_A),
         (forward_B)
          );
          
    ALU_control_unit alu_controller(
        (ID_EX_out_opcode),
        (ID_EX_out_controls[10:9]),
        (ID_EX_out_funct3),
        (ID_EX_out_inst_30),
        (ALU_signal)
        );
        
    mux_4x1 ALU_4x1_mux_1(   
         (ID_EX_out_readData1),
         (ALU_or_mem_out),
         (EX_MEM_out_ALUOut),
         (0),
         (forward_A),
         (ALU_4x1_mux_out_1)
         );
        
   mux_4x1 ALU_4x1_mux_2(   
         (ID_EX_out_readData2),
         (ALU_or_mem_out),
         (EX_MEM_out_ALUOut),
         (0),
         (forward_B),
         (ALU_4x1_mux_out_2)
         );
                 
   mux_2x1 ALU_2x1_mux_1(   
        (ALU_4x1_mux_out_1),
        (ID_EX_out_PC),
        (ID_EX_out_controls[7]), 
        (ALU_input_1)
        );
        
   mux_2x1 ALU_2x1_mux_2(   
        (ALU_4x1_mux_out_2),
        (ID_EX_out_imm),
        (ID_EX_out_controls[8]), 
        (ALU_input_2)
        );
        
    ALU alu(  
        (ID_EX_out_opcode),
        (ALU_input_1),
        (ALU_input_2),
        (ID_EX_out_rs2),
        (ALU_signal),
        (ID_EX_out_inst_25), 
        (ALU_result),
        (carry_flag),
        (zero_flag),
        (ov_flag),
        (N_flag)
        );
    
    register #(162) EX_MEM(
        (clk),
        (rst),
        (carry_on_load), 
        ({
            MEM_controls, 
            ID_EX_out_PC4, 
            pc_plus_imm, 
            carry_flag, 
            zero_flag, 
            ov_flag, 
            N_flag, 
            ALU_result,
            ALU_4x1_mux_out_2 , 
            ID_EX_out_rd, 
            ID_EX_out_rs1, 
            ID_EX_out_rs2, 
            ID_EX_out_opcode,
            ID_EX_out_funct3
        }),
        ({
            EX_MEM_out_controls, 
            EX_MEM_out_PC_plus_4, 
            EX_MEM_out_PC_plus_imm, 
            EX_MEM_out_flags, 
            EX_MEM_out_ALUOut,
            EX_MEM_out_readData2, 
            EX_MEM_out_rd, 
            EX_MEM_out_rs1, 
            EX_MEM_out_rs2, 
            EX_MEM_out_opcode, 
            EX_MEM_out_funct3
        }));
    
    branch_controller branch_controllerr(
        (EX_MEM_out_opcode),
        (EX_MEM_out_funct3),
        (EX_MEM_out_flags[3]), 
        (EX_MEM_out_flags[2]), 
        (EX_MEM_out_flags[1]), 
        (EX_MEM_out_flags[0]), 
        (EX_MEM_out_controls[6]),
        (branch_taken)
        );
    
    mux_2x1 PC_next_add_mux(
        (PC_plus_4),
        (JAL_JALR_addr),
        (branch_taken),
        (PC_input)
        );
        
    mux_2x1 JAL_JALR_addr_mux(
        (EX_MEM_out_PC_plus_imm),
        (EX_MEM_out_ALUOut),
        (EX_MEM_out_controls[3]),
        (JAL_JALR_addr)
        );
        
    register #(104) MEM_WB( 
        (clk),
        (rst),
        (carry_on_load),
        ({
            WB_controls, 
            memory_output, 
            EX_MEM_out_ALUOut, 
            EX_MEM_out_rd, 
            EX_MEM_out_PC_plus_4
        }),
        ({
            MEM_WB_out_controls, 
            MEM_WB_out_memOUT, 
            MEM_WB_out_ALUOut, 
            MEM_WB_out_rd, 
            MEM_WB_out_PC_plus_4
        }));
   
   mux_2x1 RF_write_data_mux_1(
        (MEM_WB_out_ALUOut),
        (MEM_WB_out_memOUT),
        (MEM_WB_out_controls[2]),
        (ALU_or_mem_out)
        ); 
        
    mux_2x1 RF_write_data_mux_2(
        (ALU_or_mem_out),
        (MEM_WB_out_PC_plus_4),
        (MEM_WB_out_controls[0]),
        (RF_write_data)
        );
     
      hazard_detection_unit hazard_detection_unitt( 
      (IF_ID_out_inst[`IR_rs1]),
      (IF_ID_out_inst[`IR_rs2]),
      (ID_EX_out_rd),
      (ID_EX_out_controls[5]),
      (EX_MEM_out_controls[5]),
      (stall),
      (stallSructural)
      );
        
endmodule
