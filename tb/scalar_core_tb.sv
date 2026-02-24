`timescale 1ns / 1ps

import qtpa_pkg::*;

module scalar_core_tb;

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // Core signals
    logic [31:0] instruction;
    logic [31:0] status_out;
    logic illegal;
    
    // Testbench signals
    logic [31:0] instr_mem [255:0];  // Memory to store instructions
    int instr_count;
    int cycle_count;
    int max_cycles = 1000;

    // Instantiate scalar core
    scalar_core dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .instruction   (instruction),
        .status_out    (status_out),
        .illegal       (illegal)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  // 10ns period = 100MHz
    end

    // Main testbench
    initial begin
        // Initialize
        rst_n = 1'b0;
        instruction = 32'h0;
        cycle_count = 0;
        instr_count = 0;

        // Load memory from file
        load_memory_file("memory.mem");

        // Reset sequence
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        // Run simulation
        $display("[%t] Starting scalar core simulation", $time);
        $display("Total instructions loaded: %d", instr_count);

        while (cycle_count < max_cycles && instr_count > 0) begin
            instruction = instr_mem[cycle_count % instr_count];
            
            @(posedge clk);
            
            // Print cycle information
            if (cycle_count % 10 == 0) begin
                $display("[Cycle %4d] PC=%3d, Instr=0x%08h, Status=0x%08h, Illegal=%b",
                         cycle_count, cycle_count % instr_count, instruction, status_out, illegal);
            end
            
            cycle_count++;
        end

        $display("[%t] Simulation complete after %d cycles", $time, cycle_count);
        $finish;
    end

    // Task to load memory file
    task load_memory_file(string filename);
        int fd;
        int result;
        logic [31:0] instr;
        
        fd = $fopen(filename, "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open file '%s'", filename);
            $finish;
        end
        
        instr_count = 0;
        while (!$feof(fd)) begin
            result = $fscanf(fd, "%h\n", instr);
            if (result == 1) begin
                instr_mem[instr_count] = instr;
                $display("Loaded Instruction[%3d]: 0x%08h", instr_count, instr);
                instr_count++;
            end
            
            if (instr_count >= 256) begin
                $display("WARNING: Instruction memory full (256 max), stopping load");
                break;
            end
        end
        
        $fclose(fd);
        $display("File '%s' loaded successfully with %d instructions\n", filename, instr_count);
    endtask

endmodule
