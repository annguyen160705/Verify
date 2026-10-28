// Transaction class for a simple memory interface
class mem_transaction;

    // --- Randomized fields ---
    rand bit        write;           // 1 = write, 0 = read
    rand bit [31:0] addr;            // byte address
    rand bit [31:0] wdata;           // write data (ignored for reads)
    rand bit [3:0]  byte_en;         // byte enable: which bytes are active

    // --- Constraint: address must be word-aligned (bits [1:0] always 0) ---
    constraint c_align {
        addr[1:0] == 2'b00;
    }

    // --- Constraint: address must be within the mapped region ---
    constraint c_addr_range {
        addr inside {[32'h0000_0000 : 32'h0000_FFFF]};
    }

    // --- Constraint: byte enables must have at least one active byte ---
    constraint c_byte_en {
        byte_en != 4'b0000;
    }

    // --- Constraint: for reads, byte enables must be all-ones (full-word read) ---
    // This is a conditional constraint: only active when write == 0
    constraint c_read_be {
        if (!write) byte_en == 4'b1111;
    }

endclass

module tb;

    mem_transaction tr;

    initial begin
        tr = new();

        repeat (1000) begin
            // randomize() returns 1 on success, 0 if constraints cannot be solved
            if (!tr.randomize())
                $fatal(1, "Randomization failed — check for conflicting constraints");

            // Drive the randomized transaction into the DUT
            // (actual signal driving omitted — handled by a driver in a UVM env)
            $display("op=%s addr=0x%08h be=%04b",
                     tr.write ? "WR" : "RD", tr.addr, tr.byte_en);
        end
    end

endmodule

