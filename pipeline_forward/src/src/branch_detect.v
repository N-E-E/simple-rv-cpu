module BranchDetector (
    input branch, jump,
    output branch_taken
);
    assign branch_taken = branch || jump;
endmodule