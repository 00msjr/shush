#!/usr/bin/env bash

# test_edge_cases.sh - Test edge cases for the shush utility
# This script tests various edge cases and error handling of the shush command

# Text formatting
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Path to shush script
SHUSH="./shush"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_result="$3"
  local test_description="$4"
  
  echo -e "${BLUE}[$((++TESTS_RUN))] Testing:${RESET} $test_name"
  echo -e "  ${YELLOW}Description:${RESET} $test_description"
  echo -e "  ${YELLOW}Command:${RESET} $test_command"
  
  # Run the test command
  local result
  result=$(eval "$test_command" 2>&1)
  local exit_code=$?
  
  # Check if the result matches the expected result
  if [[ "$result" == *"$expected_result"* ]]; then
    echo -e "  ${GREEN}✓ PASSED${RESET}"
    ((TESTS_PASSED++))
  else
    echo -e "  ${RED}✗ FAILED${RESET}"
    echo -e "  ${YELLOW}Expected:${RESET} $expected_result"
    echo -e "  ${YELLOW}Got:${RESET} $result"
    ((TESTS_FAILED++))
  fi
  echo
}

# Function to create test scripts
create_test_scripts() {
  # Script that produces a lot of output
  cat > heavy_output.sh << 'EOF'
#!/bin/bash
for i in {1..1000}; do
  echo "Line $i of stdout"
  echo "Line $i of stderr" >&2
done
EOF
  chmod +x heavy_output.sh

  # Script that takes arguments
  cat > echo_args.sh << 'EOF'
#!/bin/bash
echo "Arguments received: $@"
echo "Number of arguments: $#" >&2
EOF
  chmod +x echo_args.sh

  # Script with special characters
  cat > special_chars.sh << 'EOF'
#!/bin/bash
echo "Special chars: !@#$%^&*()_+<>?:\"{}|~"
echo "Quotes: 'single' and \"double\"" >&2
echo "Backticks: \`command\`"
EOF
  chmod +x special_chars.sh

  # Script that fails
  cat > failing_script.sh << 'EOF'
#!/bin/bash
echo "About to fail..."
exit 42
EOF
  chmod +x failing_script.sh
}

# Setup
echo -e "${BOLD}Setting up test environment...${RESET}"
create_test_scripts

# Begin tests
echo -e "${BOLD}Running edge case tests for shush...${RESET}\n"

# Test 1: No command provided
run_test "No Command" \
  "$SHUSH" \
  "Error: No command specified" \
  "Should show an error when no command is provided"

# Test 2: Invalid option
run_test "Invalid Option" \
  "$SHUSH --invalid-option -- echo test" \
  "Unknown option" \
  "Should show an error for invalid options"

# Test 3: Missing argument for option
run_test "Missing Option Argument" \
  "$SHUSH -l -- echo test" \
  "Error" \
  "Should handle missing arguments for options that require them"

# Test 4: Command with arguments containing spaces
run_test "Command With Spaces" \
  "$SHUSH -r -- ./echo_args.sh \"hello world\" 'quoted argument'" \
  "0" \
  "Should handle commands with arguments containing spaces"

# Test 5: Command with special characters
run_test "Special Characters" \
  "$SHUSH -l special_chars.log -- ./special_chars.sh && grep -q 'Special chars' special_chars.log && echo 'Found special chars'" \
  "Found special chars" \
  "Should handle commands with special characters"

# Test 6: Very large output
run_test "Large Output" \
  "$SHUSH -l large_output.log -- ./heavy_output.sh && grep -q 'Line 1000 of stderr' large_output.log && echo 'Found large output'" \
  "Found large output" \
  "Should handle commands that produce a lot of output"

# Test 7: Non-existent command
run_test "Non-existent Command" \
  "$SHUSH -r -- command_that_does_not_exist 2>/dev/null || echo 'Command failed'" \
  "Command failed" \
  "Should handle non-existent commands gracefully"

# Test 8: Command with unusual exit code
run_test "Unusual Exit Code" \
  "$SHUSH -r -- ./failing_script.sh || echo $?" \
  "42" \
  "Should correctly report unusual exit codes"

# Test 9: Nested shush commands
run_test "Nested Shush" \
  "$SHUSH -r -- $SHUSH -r -- echo nested" \
  "0" \
  "Should handle nested shush commands"

# Test 10: Piped commands
run_test "Piped Commands" \
  "$SHUSH -r -- 'echo test | grep test'" \
  "0" \
  "Should handle piped commands"

# Test 11: Command with redirection
run_test "Command With Redirection" \
  "$SHUSH -r -- 'echo test > redirect_test.txt && cat redirect_test.txt'" \
  "0" \
  "Should handle commands with redirection"

# Test 12: Interrupt handling (this is tricky to test automatically)
# We'll just check if the temporary files are cleaned up
run_test "Cleanup Check" \
  "$SHUSH -- echo test && find /tmp -name 'tmp.*' -user $(whoami) -mmin -1 | wc -l" \
  "0" \
  "Should clean up temporary files after execution"

# Cleanup
echo -e "${BOLD}Cleaning up test environment...${RESET}"
rm -f heavy_output.sh echo_args.sh special_chars.sh failing_script.sh
rm -f special_chars.log large_output.log redirect_test.txt

# Summary
echo -e "${BOLD}Edge Case Test Summary:${RESET}"
echo -e "${BLUE}Total tests:${RESET} $TESTS_RUN"
echo -e "${GREEN}Tests passed:${RESET} $TESTS_PASSED"
echo -e "${RED}Tests failed:${RESET} $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "\n${GREEN}All edge case tests passed!${RESET}"
  exit 0
else
  echo -e "\n${RED}Some edge case tests failed!${RESET}"
  exit 1
fi
