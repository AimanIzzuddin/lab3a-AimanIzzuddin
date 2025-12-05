#!/bin/bash
iverilog -g2012 -o sim_out *.v
vvp sim_out > result.txt

if grep -q "ALL TESTS PASSED" result.txt; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Test failed!"
    cat result.txt
    exit 1
fi
