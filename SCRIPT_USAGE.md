# A Minimal Script to Format `past-exams`

The script is run on `main` and any opened PR targeting `main`. We encourage you to run the script locally but if omitted, our GitHub actions runner will run it for you, and report any errors.

## Prerequisites

The script should be as minimal as possible. It can be executed on most Unix-like systems with a copy of `Bash` in `PATH`. However, to streamline `JSON` processing, the script requires [`jq`](https://jqlang.org/).

## Usage

### 1. Scanning

```bash
./manage-exams.sh scan
```

Scans all files in the `exams/` directory and validates:
- File naming conventions (e.g., `Exam-*`, `Answer-*`, `Combined-*`, `final_report-*`)
- Date directory format (`YYYY-MM-DD`) for each exam instance
- Courses' `README.md` files

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
- Creates automatic backup (`README.md.backup`)

### Successful Scan

```
...
✓ Found README.md in ./exams/DIT984
✓ Found README.md in ./exams/DIT348
✓ Found README.md in ./exams/DAT246


═══════════════════════════════════════
           VALIDATION SUMMARY
═══════════════════════════════════════
✓ No errors found!
═══════════════════════════════════════
```

### Scan with Errors

TODO

## JSON Data Files

The script relies on three JSON files for rich metadata (see respective *schema* files in `descriptionCreator/schemas/*`):

- **`programmes.json`**: Programme definitions (name, type, etc.)
- **`programmeOrders.json`**: Term structure and course ordering per programme
- **`courses.json`**: Course names and programme associations