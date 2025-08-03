# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a bash script project for a group assignment ("Proyecto Final - Script Grupal") focused on file comparison functionality using Git or diff utilities. The project is structured as a menu-driven script where different team members contribute different functionalities.

## Architecture

### Core Structure
- `src/main_script.sh` - Main executable script containing:
  - Interactive menu system for accessing different functionalities
  - `comparar_cambios()` function - Git/diff comparison tool (completed feature)
  - Placeholder functions for other team members' contributions
  - Global variables for student info, group identifier, and date handling

### Testing Structure
- `tests/test_comparar_cambios.sh` - Automated test suite for the comparison functionality
  - Creates temporary Git repositories for testing
  - Tests both Git branch comparison and file/directory diff modes
  - Includes assertion functions for verifying output files

## Development Commands

### Running the Main Script
```bash
bash src/main_script.sh
```

### Running Tests
```bash
bash tests/test_comparar_cambios.sh
```

### Making Scripts Executable
```bash
chmod +x src/main_script.sh
chmod +x tests/test_comparar_cambios.sh
```

## Key Functionality Details

### Comparison Feature (`comparar_cambios`)
- **Mode 1**: Git branch comparison - generates patch files and reports
- **Mode 2**: File/directory diff comparison using `diff -ru`
- Outputs saved to `$HOME` directory with date stamps
- Report files follow naming convention: `${GRUPO}_comparacion-${DATE}.txt`

### File Output Locations
- Git patches: `$HOME/diff_${BASE}vs${COMPARE}-${DATE}.patch`
- Diff files: `$HOME/diff_${DATE}.txt`
- Reports: `$HOME/${GRUPO}_comparacion-${DATE}.txt`

## Project Variables
- `GRUPO="Grupo1"` - Team identifier used in output files
- `ESTUDIANTE` and `DESCRIPCION` - Student-specific metadata
- Date formatting uses `date +%F` (YYYY-MM-DD format)

## Dependencies
- Standard bash utilities: `git`, `diff`, `pwd`, `date`
- All error handling includes checks for command availability and Git repository status