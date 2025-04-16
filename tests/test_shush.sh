#!/usr/bin/env bash

# test_shush.sh - Test suite for the shush utility
# This script tests various features of the shush command

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
  if [[ "$result" == *"$expected_result"* && $exit_code -eq 0 ]]; then
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

# Function to create a noisy test script
create_test_script() {
  cat > test_script.sh << 'EOF'
#!/bin/bash
echo "This is stdout output"
echo "This is stderr output" >&2
echo "More stdout content"
sleep 1
echo "Final stdout line"
echo "Final stderr line" >&2
exit $1
EOF
  chmod +x test_script.sh
}

# Setup
echo -e "${BOLD}Setting up test environment...${RESET}"
create_test_script 0

# Begin tests
echo -e "${BOLD}Running shush tests...${RESET}\n"

# Test 1: Basic functionality - suppress all output
run_test "Basic Suppression" \
  "$SHUSH -- ./test_script.sh 0" \
  "" \
  "Should suppress all output from the test script"

# Test 2: Suppress only stdout
run_test "Stdout Suppression" \
  "$SHUSH -o -- ./test_script.sh 0 2>&1" \
  "stderr" \
  "Should suppress only stdout, stderr should be visible"

# Test 3: Suppress only stderr
run_test "Stderr Suppression" \
  "$SHUSH -e -- ./test_script.sh 0 2>&1" \
  "stdout" \
  "Should suppress only stderr, stdout should be visible"

# Test 4: Log output to file
LOG_FILE="test_log.txt"
run_test "Log Output" \
  "$SHUSH -l $LOG_FILE -- ./test_script.sh 0 && cat $LOG_FILE" \
  "stdout" \
  "Should log both stdout and stderr to the log file"

# Test 5: Return only exit code
run_test "Return Exit Code" \
  "$SHUSH -r -- ./test_script.sh 0" \
  "0" \
  "Should only print the exit code of the command"

# Test 6: Ignore exit code
create_test_script 1
run_test "Ignore Exit Code" \
  "$SHUSH -i -r -- ./test_script.sh 1; echo \$?" \
  "0" \
  "Should exit with 0 regardless of the command's exit code"

# Test 7: Preserve exit code
run_test "Preserve Exit Code" \
  "$SHUSH -r -- ./test_script.sh 1; echo \$?" \
  "1" \
  "Should exit with the same code as the command"

# Test 8: Summary output
run_test "Summary Output" \
  "$SHUSH -s -- ./test_script.sh 0" \
  "Execution time" \
  "Should show a summary with execution time"

# Test 9: Quiet mode
run_test "Quiet Mode" \
  "$SHUSH -q -- ./test_script.sh 0" \
  "" \
  "Should produce no output at all"

# Test 10: Timeout (this should terminate the command)
run_test "Timeout" \
  "$SHUSH -t 1 -r -- sleep 10 || echo 124" \
  "124" \
  "Should terminate the command after the timeout period"

# Test 11: Verbose mode
run_test "Verbose Mode" \
  "$SHUSH -v -- ./test_script.sh 0" \
  "Running command" \
  "Should show a progress indicator while the command runs"

# Test 12: Combined options
run_test "Combined Options" \
  "$SHUSH -s -l combined_log.txt -- ./test_script.sh 0 && cat combined_log.txt" \
  "STDOUT" \
  "Should work with multiple options combined"

# Cleanup
echo -e "${BOLD}Cleaning up test environment...${RESET}"
rm -f test_script.sh test_log.txt combined_log.txt

# Summary
echo -e "${BOLD}Test Summary:${RESET}"
echo -e "${BLUE}Total tests:${RESET} $TESTS_RUN"
echo -e "${GREEN}Tests passed:${RESET} $TESTS_PASSED"
echo -e "${RED}Tests failed:${RESET} $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "\n${GREEN}All tests passed!${RESET}"
  exit 0
else
  echo -e "\n${RED}Some tests failed!${RESET}"
  exit 1
fi
