module time_out #(parameter TIMEOUT_COUNT = 10)(
    input wire PCLK,
    input  wire PRESETn,
    input wire start,
    output reg timed_out
);
    reg [$clog2(TIMEOUT_COUNT)-1:0] count;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            timed_out <= 0;
            count <= 0;
        end
        else begin
            if (!start) begin // if timer stopped, reset
                count <= 0;
                timed_out <= 0;
            end
            else if (!timed_out) begin // count till timer is stopped
                if (count == TIMEOUT_COUNT-1) timed_out <= 1;
                else count <= count + 1;
            end
        end
    end

endmodule //time_out
