# Exam Management Script Usage

## Overview

The `manage-exams.sh` script is a bash script that helps manage the past-exams repository by:

1. **Validating** file naming conventions
2. **Scanning** the repository structure
3. **Generating** README.md files organized by programmes and terms
4. **Updating** exam counts automatically
5. **Creating** GitHub links for easy navigation

## What is an "Exam"?

In this repository, an **exam** is defined as one date instance (YYYY-MM-DD directory) that may contain any combination of these files:

- `Exam-courseCode-YYMMDD.pdf` - The exam questions
- `Answer-courseCode-YYMMDD-anonymCode.pdf` - Student answers (with anonymous code)
- `Answer-courseCode-YYMMDD-official.pdf` - Official teacher answers
- `Combined-courseCode-YYMMDD-official.pdf` - Exam with official answers
- `Combined-courseCode-YYMMDD-anonymCode.pdf` - Exam with student answers

**Example:** A directory `2024-10-30/` containing an exam PDF, two answer PDFs, and a combined PDF counts as **1 exam**, not 4 separate items.

## Prerequisites

- **jq** - JSON processor (required for programme-based README generation)
  - macOS: `brew install jq`
  - Linux: `sudo apt-get install jq` or `sudo yum install jq`

## Commands

### 1. Scan & Validate

```bash
./manage-exams.sh scan
```

Scans all files in the `exams/` directory and validates:
- File naming conventions (Exam-*, Answer-*, Combined-*, final_report-*)
- Date directory format (YYYY-MM-DD)
- Course README.md existence

**Exit codes:**
- 0: No errors found
- N: Number of errors found (non-zero)

### 2. Rebuild README.md

```bash
./manage-exams.sh rebuild
```

Completely rebuilds the main `README.md` file:
- Organizes courses by programmes (using JSON data files)
- Groups courses by terms/study periods within each programme
- Shows exam counts for each course (counting by date directories)
- Creates automatic backup (README.md.backup)
- Generates GitHub URLs for course links

**Features:**
- **Prioritizes programmes with term ordering**: Programmes defined in `programmeOrders.json` appear first, in the order they are defined
- **Alphabetical fallback**: Remaining programmes appear alphabetically
- Reads from `descriptionCreator/data/programmes.json`
- Reads from `descriptionCreator/data/programmeOrders.json`
- Reads from `descriptionCreator/data/courses.json`
- Falls back to simple list if JSON files not found
- All course links use GitHub URLs: `https://github.com/skipgu/past-exams/tree/main/exams/DITXXX`

### 3. Update Exam Counts

```bash
./manage-exams.sh update
```

Updates only the exam counts in existing README.md without changing structure:
- Useful for quick updates after adding new exams
- Preserves existing formatting and organization
- Recounts exams based on date directories (not individual files)
- Updates GitHub URLs if needed

### 4. Help

```bash
./manage-exams.sh help
# or
./manage-exams.sh --help
./manage-exams.sh -h
```

Displays usage information and available commands.

## File Structure Requirements

### Expected Naming Conventions

#### Exam Files
```
Exam-DITXXX-YYMMDD.pdf
Exam-DIT009-241030.pdf
Exam-DIT032_DIT033_DAT335-220817.pdf  # Multiple course codes
```

#### Answer Files
```
Answer-DITXXX-YYMMDD-official.pdf         # Official answer
Answer-DITXXX-YYMMDD-official_partial.pdf # Partial official answer
Answer-DIT009-241030-673.pdf              # Student answer with anonym code
Answer-DIT431-231027-DIT431_0007_ADT.pdf  # Full format anonym code
```

#### Combined Files
```
Combined-DITXXX-YYMMDD-official.pdf       # Exam + official answer
Combined-DIT633-230316-DIT633-0030-YTW.pdf # Exam + student answer
```

#### Final Reports
```
final_report-DITXXX-id-GRADE.pdf
final_report-DIT347-009-VG.pdf
final_report-DIT347-008-G.pdf
```

### Directory Structure
```
exams/
├── DITXXX/
│   ├── README.md                                      # Course overview
│   ├── YYYY-MM-DD/                                    # One exam instance (counts as 1 exam)
│   │   ├── Exam-DITXXX-YYMMDD.pdf                   # Exam questions
│   │   ├── Answer-DITXXX-YYMMDD-anonymCode.pdf      # Student answers
│   │   ├── Answer-DITXXX-YYMMDD-official.pdf        # Official answers
│   │   ├── Combined-DITXXX-YYMMDD-official.pdf      # Exam + official answers
│   │   └── Combined-DITXXX-YYMMDD-anonymCode.pdf    # Exam + student answers
│   └── YYYY-MM-DD/                                    # Another exam instance (counts as 1 exam)
│       └── ...
└── DITYYY/
    └── ...
```

**Note:** Each `YYYY-MM-DD` directory represents **one exam**, regardless of how many PDF files it contains.

## Workflow for Contributors

### Adding New Exams

1. **Add PDF files** to appropriate course directory:
   ```bash
   exams/DIT009/2024-10-30/
   ```

2. **Run validation**:
   ```bash
   ./manage-exams.sh scan
   ```

3. **Fix any errors** reported by the script

4. **Rebuild README.md**:
   ```bash
   ./manage-exams.sh rebuild
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "Add exams for DIT009"
   ```

### Adding New Course

1. **Create course directory**:
   ```bash
   mkdir -p exams/DIT999
   ```

2. **Add course to JSON data** (if not already there):
   - Update `descriptionCreator/data/courses.json`
   - Update `descriptionCreator/data/programmeOrders.json` if needed

3. **Run scan to create README template**:
   ```bash
   ./manage-exams.sh scan
   ```

4. **Edit course README.md** to add proper course name

5. **Rebuild main README.md**:
   ```bash
   ./manage-exams.sh rebuild
   ```

## Output Examples

### Successful Scan
```
ℹ Scanning ./exams...

✓ Valid: exams/DIT009/2024-10-30/Exam-DIT009-241030.pdf
✓ Valid: exams/DIT009/2024-10-30/Answer-DIT009-241030-official.pdf

ℹ Checking course README files...

✓ Valid: exams/DIT009/README.md

═══════════════════════════════════════
           VALIDATION SUMMARY
═══════════════════════════════════════
✓ No errors found!
═══════════════════════════════════════
```

### Scan with Errors
```
ℹ Scanning ./exams...

✗ ERROR: Invalid exam filename: exam-dit009.pdf (expected Exam-DITXXX-YYMMDD.pdf)
⚠ WARNING: File in invalid date directory: exams/DIT009/2024-10/exam.pdf

═══════════════════════════════════════
           VALIDATION SUMMARY
═══════════════════════════════════════
✗ ERROR: 1 error(s) found
⚠ WARNING: 1 warning(s) found
═══════════════════════════════════════
```

## Advanced Features

### Color-coded Output
- 🔴 **Red**: Errors (must be fixed)
- 🟡 **Yellow**: Warnings (should be reviewed)
- 🟢 **Green**: Success messages
- 🔵 **Blue**: Information messages

### Automatic Backups
When rebuilding README.md, the script automatically creates `README.md.backup` to preserve the previous version.

### Error Counting
The script tracks and reports:
- Number of errors found
- Number of warnings issued
- Number of items automatically fixed

### Programme Ordering
The script intelligently orders programmes in the README:
1. **First**: Programmes with term ordering (from `programmeOrders.json`), in their defined order
2. **Then**: Remaining programmes alphabetically

This ensures that well-structured programmes with term-based course organization are prominently displayed.

### Exam Counting Logic
The script counts exams by **date directories**, not individual PDF files:
- Each `YYYY-MM-DD` directory = 1 exam
- Directory must contain at least one exam-related PDF (Exam-*, Answer-*, or Combined-*)
- Empty date directories are not counted

### GitHub URL Generation
All course links in the README use full GitHub URLs:
- Format: `https://github.com/skipgu/past-exams/tree/main/exams/DITXXX`
- Allows users to click directly to view course contents on GitHub
- Works in both the repository and when viewing README elsewhere

### Fallback Mechanism
If JSON data files are not available or jq is not installed, the script falls back to generating a simple course list instead of programme-organized sections.

## Troubleshooting

### "jq is not installed"
Install jq using your package manager. The script will still work but will use simple course listing instead of programme organization.

### "Missing README.md in course directory"
The script will offer to create a template README.md for you. Press 'y' to accept.

### "Invalid filename" errors
Rename files to match the expected naming convention. Refer to the "File Structure Requirements" section above.

## Key Concepts

### Exam Definition
An **exam** = one date directory (YYYY-MM-DD) containing exam-related files. This means:
- ✅ `2024-10-30/` with 1 PDF = **1 exam**
- ✅ `2024-10-30/` with 5 PDFs (Exam + Answers + Combined) = **1 exam**
- ❌ Empty `2024-10-30/` directory = **0 exams**

### Programme Organization
The README organizes courses hierarchically:
1. **Programme level**: Bachelor/Master programmes (e.g., "Software Engineering")
2. **Term level**: Study periods (e.g., "Year 1, Period 1")
3. **Course level**: Individual courses (e.g., "DIT009 - Introduction to Programming")

### JSON Data Files
The script relies on three JSON files for rich metadata:

- **`programmes.json`**: Programme definitions (name, type, etc.)
- **`programmeOrders.json`**: Term structure and course ordering per programme
- **`courses.json`**: Course names and programme associations

## Future Enhancements

Potential features to add:
- Automatic file renaming suggestions
- Duplicate detection across courses
- Statistics dashboard generation
- JSON schema validation
- Course-level README auto-generation
- Exam date validation (checking YYYY-MM-DD matches YYMMDD in filenames)
