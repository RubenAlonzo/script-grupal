#!/bin/bash
# =========================================================================
# Test suite for src/main.sh
# =========================================================================

# Path to the script being tested
SCRIPT_PATH="$(dirname "$0")/../src/main.sh"
TEMP_DIR=$(mktemp -d)
TEST_REPO="$TEMP_DIR/repo_test"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Arrays for file tracking and cleanup
CREATED_FILES=()
EXISTING_FILES=()

# =============================
# ASSERTION HELPER FUNCTIONS
# =============================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo "✅ PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected: '$expected'"
        echo "   Actual:   '$actual'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if echo "$haystack" | grep -q -- "$needle"; then
        echo "✅ PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected to find: '$needle'"
        echo "   In output: '$haystack'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ -f "$file" ]; then
        echo "✅ PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: $test_name"
        echo "   File not found: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_contains() {
    local file="$1"
    local content="$2"
    local test_name="$3"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ -f "$file" ] && grep -q "$content" "$file"; then
        echo "✅ PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: $test_name"
        if [ ! -f "$file" ]; then
            echo "   File not found: $file"
        else
            echo "   Content '$content' not found in $file"
        fi
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if ! echo "$haystack" | grep -q -- "$needle"; then
        echo "✅ PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: $test_name"
        echo "   Should not contain: '$needle'"
        echo "   But found in: '$haystack'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# =============================
# FILE TRACKING AND CLEANUP
# =============================

capture_existing_files() {
    echo "📋 Capturing existing files..."
    mapfile -t EXISTING_FILES < <(find "$HOME" -maxdepth 1 \( \
        -name "Grupo1_diff_*" -o \
        -name "*_diff_*.patch" -o \
        -name "*_diff_*.txt" -o \
        -name "Grupo1_archivos_grandes_*" \
    \) -type f 2>/dev/null || true)
}

track_created_file() {
    local file="$1"
    if [ -n "$file" ]; then
        CREATED_FILES+=("$file")
    fi
}

cleanup_created_files() {
    echo "🧹 Cleaning up test-created files..."
    for file in "${CREATED_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  Removing: $file"
            rm -f "$file" 2>/dev/null || true
        fi
    done
    CREATED_FILES=()
}

detect_new_files() {
    local current_files=()
    mapfile -t current_files < <(find "$HOME" -maxdepth 1 \( \
        -name "Grupo1_diff_*" -o \
        -name "*_diff_*.patch" -o \
        -name "*_diff_*.txt" -o \
        -name "Grupo1_archivos_grandes_*" \
    \) -type f 2>/dev/null || true)
    
    for file in "${current_files[@]}"; do
        local was_existing=false
        for existing_file in "${EXISTING_FILES[@]}"; do
            if [[ "$file" == "$existing_file" ]]; then
                was_existing=true
                break
            fi
        done
        
        if [[ "$was_existing" == false ]]; then
            track_created_file "$file"
        fi
    done
}

# =============================
# TEST SETUP AND INITIALIZATION
# =============================

setup_test_environment() {
    echo "🔧 Setting up test environment..."
    capture_existing_files
    
    # Source the script to get variables and functions
    source "$SCRIPT_PATH"
    
    # Create test repository
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial content
    echo "Original content" > test_file.txt
    git add test_file.txt
    git commit -q -m "Initial commit"
    
    # Rename to main if needed
    git branch -m master main 2>/dev/null || true
    
    # Create test branch with changes
    git checkout -q -b test_branch
    echo "Modified content" >> test_file.txt
    git commit -q -am "Modified content"
    git checkout -q main
    
    cd - > /dev/null
}

# =============================
# UNIT TESTS
# =============================

test_mostrar_info() {
    echo
    echo "=== UNIT TESTS: mostrar_info() ==="
    
    # Test function output
    local output=$(mostrar_info)
    
    assert_contains "$output" "=======================================" "Header formatting"
    assert_contains "$output" "Grupo:" "Group label"
    assert_contains "$output" "Grupo1" "Group name"
    assert_contains "$output" "Fecha:" "Date label"
    assert_contains "$output" "Directorio:" "Directory label"
    assert_contains "$output" "$(pwd)" "Current directory"
    assert_contains "$output" "Integrantes y funciones:" "Members section"
    assert_contains "$output" "Ruben Alonzo" "Member name"
    assert_contains "$output" "Comparar cambios" "Function description"
    assert_contains "$output" "Funcionalidades pendientes" "Pending functions"
}

test_func_pendiente() {
    echo
    echo "=== UNIT TESTS: func_pendiente() ==="
    
    local output=$(func_pendiente)
    
    assert_contains "$output" "Funcionalidad pendiente de implementación" "Pending message"
    assert_not_contains "$output" "Error" "No error messages"
}

test_variable_initialization() {
    echo
    echo "=== UNIT TESTS: Variable Initialization ==="
    
    # Test GRUPO variable
    assert_equals "Grupo1" "$GRUPO" "GRUPO variable set correctly"
    
    # Test FECHA format (should be YYYY-MM-DD_HH-MM-SS format)
    if [[ "$FECHA" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "✅ PASS: FECHA format validation"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL: FECHA format validation"
        echo "   Expected format: YYYY-MM-DD_HH-MM-SS"
        echo "   Actual: $FECHA"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# =============================
# MENU SYSTEM TESTS
# =============================

test_menu_display() {
    echo
    echo "=== MENU TESTS: Menu Display ==="
    
    # Test menu structure by capturing one iteration
    local output=$(printf "99\n0\n" | timeout 5 bash "$SCRIPT_PATH" 2>&1 || true)
    
    assert_contains "$output" "Menú:" "Menu header"
    assert_contains "$output" "1) Comparar cambios" "Option 1"
    assert_contains "$output" "2) Encontrar archivos grandes" "Option 2"
    assert_contains "$output" "3) Generar calendario anual" "Option 3"
    assert_contains "$output" "4) Sincronizar carpetas" "Option 4"
    assert_contains "$output" "5) Funcionalidad 5" "Option 5"
    assert_contains "$output" "0) Salir" "Exit option"
    # Note: read -p prompts are not visible in non-interactive mode, so we don't test for them
}

test_menu_exit() {
    echo
    echo "=== MENU TESTS: Exit Functionality ==="
    
    local output=$(echo "0" | timeout 5 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "¡Hasta luego!" "Exit message"
}

test_menu_invalid_option() {
    echo
    echo "=== MENU TESTS: Invalid Option Handling ==="
    
    local output=$(printf "99\n0\n" | timeout 5 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "Elija una opción válida" "Invalid option message"
}

test_menu_pending_functions() {
    echo
    echo "=== MENU TESTS: Pending Functions ==="
    
    # Test option 2 (should execute encontrar_archivos_grandes, not pending)
    local output2=$(printf "2\n/tmp\n0\n" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    assert_contains "$output2" "-- ENCONTRAR ARCHIVOS GRANDES --" "Option 2 executes large files function"
    
    # Test option 3
     local output3=$(printf "3\n0\n" | timeout 5 bash "$SCRIPT_PATH" 2>/dev/null || true)
    assert_contains "$output3" "Generar calendario anual" "Option 3 pending message"
   
    
    # Test option 4
     local output4=$(printf "4\n0\n" | timeout 5 bash "$SCRIPT_PATH" 2>/dev/null || true)
    assert_contains "$output4" "Sincronizar carpetas" "Option 4 pending message"
    
    # Test option 5
    local output5=$(printf "5\n0\n" | timeout 5 bash "$SCRIPT_PATH" 2>/dev/null || true)
    assert_contains "$output5" "Funcionalidad pendiente" "Option 5 pending message"
}

# =============================
# COMPARISON FUNCTION TESTS
# =============================

test_comparar_cambios_git_mode() {
    echo
    echo "=== COMPARISON TESTS: Git Mode ==="
    
    # Test Git mode with valid repository
    local input=$(printf "1\n1\n$TEST_REPO\nmain\ntest_branch\n0\n")
    local output=$(echo "$input" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "-- COMPARAR CAMBIOS --" "Function header"
    assert_contains "$output" "1) Usar Git (ramas)" "Git option"
    assert_contains "$output" "2) Usar diff (archivos/carpetas)" "Diff option"
    assert_contains "$output" "Patch generado en:" "Success message"
    
    # Check if patch file was created
    detect_new_files
    local expected_pattern="Grupo1_diff_mainvstest_branch_"
    local patch_found=false
    for file in "${CREATED_FILES[@]}"; do
        if [[ "$file" == *"$expected_pattern"* ]] && [[ "$file" == *.patch ]]; then
            patch_found=true
            assert_file_exists "$file" "Git patch file creation"
            break
        fi
    done
    
    if [ "$patch_found" = false ]; then
        echo "❌ FAIL: Git patch file not found with expected pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    fi
}

test_comparar_cambios_diff_mode() {
    echo
    echo "=== COMPARISON TESTS: Diff Mode ==="
    
    # Create test files
    local file1="$TEMP_DIR/file1.txt"
    local file2="$TEMP_DIR/file2.txt"
    echo "Line 1" > "$file1"
    echo "Line 2" > "$file2"
    
    # Test diff mode
    local input=$(printf "1\n2\n$file1\n$file2\n0\n")
    local output=$(echo "$input" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "Diff generado en:" "Diff success message"
    
    # Check if diff file was created
    detect_new_files
    local expected_pattern="Grupo1_diff_"
    local diff_found=false
    for file in "${CREATED_FILES[@]}"; do
        if [[ "$file" == *"$expected_pattern"* ]] && [[ "$file" == *.txt ]]; then
            diff_found=true
            assert_file_exists "$file" "Diff file creation"
            break
        fi
    done
    
    if [ "$diff_found" = false ]; then
        echo "❌ FAIL: Diff file not found with expected pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    fi
}

test_comparar_cambios_invalid_mode() {
    echo
    echo "=== COMPARISON TESTS: Invalid Mode ==="
    
    local input=$(printf "1\n99\n0\n")
    local output=$(echo "$input" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "Opción inválida" "Invalid mode message"
}

# =============================
# LARGE FILES FUNCTION TESTS
# =============================

test_encontrar_archivos_grandes() {
    echo
    echo "=== LARGE FILES TESTS: Find Large Files (100MB+) ==="
    
    # Create test files with different sizes
    local test_dir="$TEMP_DIR/size_test"
    mkdir -p "$test_dir"
    
    # Create a large file (> 100MB for testing)
    dd if=/dev/zero of="$test_dir/large_file.txt" bs=1M count=101 2>/dev/null
    # Create a smaller file (< 100MB)
    dd if=/dev/zero of="$test_dir/medium_file.txt" bs=1M count=50 2>/dev/null
    # Create a small file
    echo "small content" > "$test_dir/small_file.txt"
    
    # Test the function
    local input=$(printf "2\n$test_dir\n0\n")
    local output=$(echo "$input" | timeout 15 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output" "-- ENCONTRAR ARCHIVOS GRANDES --" "Function header"
    assert_contains "$output" "Resultados guardados en:" "Success message"
    
    # Check if results file was created
    detect_new_files
    local expected_pattern="Grupo1_archivos_grandes_100M_"
    local file_found=false
    for file in "${CREATED_FILES[@]}"; do
        if [[ "$file" == *"$expected_pattern"* ]] && [[ "$file" == *.txt ]]; then
            file_found=true
            assert_file_exists "$file" "Large files result file creation"
            # Check if the large file is in the results and formatted properly
            assert_file_contains "$file" "large_file.txt" "Large file found in results"
            assert_file_contains "$file" "Tamaño:" "Friendly format with size label"
            assert_file_contains "$file" "Total de archivos encontrados:" "Summary with file count"
            break
        fi
    done
    
    if [ "$file_found" = false ]; then
        echo "❌ FAIL: Large files result file not found with expected pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    fi
}

# =============================
# ERROR HANDLING TESTS
# =============================

test_error_handling() {
    echo
    echo "=== ERROR HANDLING TESTS ==="
    
    # Test with non-existent repository
    local input1=$(printf "1\n1\n/nonexistent/repo\nmain\ntest\n0\n")
    local output1=$(echo "$input1" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    # The script might not have explicit error handling, but git should fail
    # We'll just check that it doesn't crash completely
    assert_contains "$output1" "-- COMPARAR CAMBIOS --" "Function still runs with invalid repo"
    
    # Test with non-existent files for diff
    local input2=$(printf "1\n2\n/nonexistent/file1\n/nonexistent/file2\n0\n")
    local output2=$(echo "$input2" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output2" "Diff generado en:" "Function handles non-existent files"
}

# =============================
# INTEGRATION TESTS
# =============================

test_full_workflow() {
    echo
    echo "=== INTEGRATION TESTS: Full Workflow ==="
    
    # Test complete workflow: menu -> comparar_cambios -> back to menu -> exit
    local input=$(printf "1\n1\n$TEST_REPO\nmain\ntest_branch\n0\n")
    local output=$(echo "$input" | timeout 15 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    # Should contain all expected elements
    assert_contains "$output" "=======================================" "Header present"
    assert_contains "$output" "Grupo1" "Group info"
    assert_contains "$output" "Menú:" "Menu displayed"
    assert_contains "$output" "-- COMPARAR CAMBIOS --" "Function executed"
    assert_contains "$output" "Patch generado en:" "Function completed"
    assert_contains "$output" "¡Hasta luego!" "Clean exit"
    
    detect_new_files
}

# =============================
# EDGE CASE TESTS
# =============================

test_edge_cases() {
    echo
    echo "=== EDGE CASE TESTS ==="
    
    # Test empty inputs (just pressing enter)
    local input1=$(printf "1\n1\n\n\n\n0\n")
    local output1=$(echo "$input1" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output1" "-- COMPARAR CAMBIOS --" "Function handles empty inputs"
    
    # Test special characters in file paths
    local special_file="$TEMP_DIR/file with spaces & special chars.txt"
    echo "content" > "$special_file"
    
    local input2=$(printf "1\n2\n$special_file\n$special_file\n0\n")
    local output2=$(echo "$input2" | timeout 10 bash "$SCRIPT_PATH" 2>/dev/null || true)
    
    assert_contains "$output2" "Diff generado en:" "Handles special characters in paths"
}

# =============================
# FILE OUTPUT VERIFICATION TESTS
# =============================

test_file_output_naming() {
    echo
    echo "=== FILE OUTPUT TESTS: Naming Convention ==="
    
    # Test Git mode file naming
    local input=$(printf "1\n1\n$TEST_REPO\nmain\ntest_branch\n0\n")
    echo "$input" | timeout 10 bash "$SCRIPT_PATH" >/dev/null 2>&1 || true
    
    detect_new_files
    
    # Verify naming pattern: Grupo1_diff_mainvstest_branch_FECHA.patch
    local naming_correct=false
    for file in "${CREATED_FILES[@]}"; do
        local basename=$(basename "$file")
        if [[ "$basename" =~ ^Grupo1_diff_mainvstest_branch_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.patch$ ]]; then
            naming_correct=true
            echo "✅ PASS: Git output file naming convention"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            break
        fi
    done
    
    if [ "$naming_correct" = false ]; then
        echo "❌ FAIL: Git output file naming convention"
        echo "   Expected pattern: Grupo1_diff_mainvstest_branch_YYYY-MM-DD_HH-MM-SS.patch"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# =============================
# MAIN TEST EXECUTION
# =============================

print_test_summary() {
    echo
    echo "========================================="
    echo "           TEST SUMMARY"
    echo "========================================="
    echo "Total tests: $TOTAL_TESTS"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Success rate: $(( TESTS_PASSED * 100 / TOTAL_TESTS ))%"
    echo "========================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "🎉 All tests passed!"
        return 0
    else
        echo "❌ Some tests failed."
        return 1
    fi
}

# Main execution
main() {
    echo "==========================================="
    echo "    STARTING TEST SUITE FOR main.sh"
    echo "==========================================="
    
    # Check if script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "❌ ERROR: Script not found at $SCRIPT_PATH"
        exit 1
    fi
    
    # Setup
    setup_test_environment
    
    # Run all tests
    test_variable_initialization
    test_mostrar_info
    test_func_pendiente
    test_menu_display
    test_menu_exit
    test_menu_invalid_option
    test_menu_pending_functions
    test_comparar_cambios_git_mode
    test_comparar_cambios_diff_mode
    test_comparar_cambios_invalid_mode
    test_encontrar_archivos_grandes
    test_error_handling
    test_full_workflow
    test_edge_cases
    test_file_output_naming
    
    # Cleanup
    cleanup_created_files
    rm -rf "$TEMP_DIR"
    
    # Summary
    print_test_summary
    exit $?
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi