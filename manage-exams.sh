#!/usr/bin/env bash
# filepath: manage-exams.sh

set -uo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
FIXED=0

# Function to print colored messages
error() { echo -e "${RED}✗ ERROR: $1${NC}" >&2; ((ERRORS++)); }
warning() { echo -e "${YELLOW}⚠ WARNING: $1${NC}"; ((WARNINGS++)); }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}ℹ $1${NC}"; }

# Function to count exams in a course directory
# An "exam" is defined as one date instance that may contain:
# - Exam-courseCodes-YYMMDD.pdf
# - Answer-courseCode-YYMMDD-anonymCode.pdf
# - Answer-courseCode-YYMMDD-official.pdf
# - Combined-courseCode-YYMMDD-official.pdf
# - Combined-courseCode-YYMMDD-anonymCode.pdf
count_exams() {
    local course_dir="$1"
    local count=0
    
    # Count unique date directories (YYYY-MM-DD format)
    # Each date directory represents one exam instance
    while IFS= read -r -d '' date_dir; do
        local dir_name=$(basename "$date_dir")
        # Check if directory name matches YYYY-MM-DD format
        if [[ "$dir_name" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            # Check if directory contains at least one exam-related PDF
            if find "$date_dir" -maxdepth 1 -type f \( -name "Exam-*.pdf" -o -name "Answer-*.pdf" -o -name "Combined-*.pdf" \) -print -quit 2>/dev/null | grep -q .; then
                ((count++))
            fi
        fi
    done < <(find "$course_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    
    echo "$count"
}

# Function to extract course name from README.md
get_course_name() {
    local course_dir="$1"
    local readme="$course_dir/README.md"
    
    if [[ -f "$readme" ]]; then
        # Extract course name from "## DITXXX - Course Name" format
        local name=$(grep -m 1 "^## " "$readme" | sed 's/^## [A-Z0-9]* - //')
        echo "$name"
    else
        echo "Course Name"
    fi
}

# Function to validate file naming convention
validate_filename() {
    local file="$1"
    local basename=$(basename "$file")
    local dirname=$(dirname "$file")
    
    # Skip non-PDF files
    [[ "$basename" != *.pdf ]] && return 0
    
    # Extract date from path (format: YYYY-MM-DD)
    local date_dir=$(basename "$dirname")
    if [[ ! "$date_dir" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        warning "File in invalid date directory: $file (expected YYYY-MM-DD format)"
        return 1
    fi
    
    # Validate filename patterns
    case "$basename" in
        Exam-*.pdf)
            # Format: Exam-courseCode(s)-YYMMDD.pdf
            if [[ ! "$basename" =~ ^Exam-[A-Z]{3}[0-9]{3}(_[A-Z]{3}[0-9]{3})*-[0-9]{6}\.pdf$ ]]; then
                error "Invalid exam filename: $basename (expected Exam-DITXXX-YYMMDD.pdf)"
                return 1
            fi
            ;;
        Answer-*.pdf)
            # Format: Answer-courseCode-YYMMDD-{official|official_partial|anonymCode}.pdf
            if [[ ! "$basename" =~ ^Answer-[A-Z]{3}[0-9]{3}-[0-9]{6}-(official|official_partial|[A-Z0-9_-]+)\.pdf$ ]]; then
                error "Invalid answer filename: $basename (expected Answer-DITXXX-YYMMDD-{official|code}.pdf)"
                return 1
            fi
            ;;
        Combined-*.pdf)
            # Format: Combined-courseCode-YYMMDD-{official|official_partial|anonymCode}.pdf
            if [[ ! "$basename" =~ ^Combined-[A-Z]{3}[0-9]{3}-[0-9]{6}-(official|official_partial|[A-Z0-9_-]+)\.pdf$ ]]; then
                error "Invalid combined filename: $basename (expected Combined-DITXXX-YYMMDD-{official|code}.pdf)"
                return 1
            fi
            ;;
        final_report-*.pdf)
            # Format: final_report-courseCode-id-grade.pdf
            if [[ ! "$basename" =~ ^final_report-[A-Z]{3}[0-9]{3}-[0-9]+-[A-Z]+\.pdf$ ]]; then
                error "Invalid final report filename: $basename (expected final_report-DITXXX-id-GRADE.pdf)"
                return 1
            fi
            ;;
        *)
            warning "Unknown file type: $basename (will not be counted in statistics)"
            ;;
    esac
    
    success "Valid: $file"
    return 0
}

# Function to check if README.md exists in course directory
check_course_readme() {
    local course_dir="$1"
    local readme="$course_dir/README.md"
    
    if [[ ! -f "$readme" ]]; then
        error "Missing README.md in $course_dir"
        
        # Offer to create template
        read -p "Create README.md template? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local course_code=$(basename "$course_dir")
            cat > "$readme" <<EOF
## $course_code - Course Name
Welcome to the $course_code - Course Name, where we've compiled past exams and student answers to assist in your preparation for this course.

Here's what we have so far:

|    Date    | Questions | Answers |   Notes   |
|------------|-----------|---------|-----------|
| YYYY-MM-DD | Yes       | Yes     |           |
EOF
            success "Created README.md template in $course_dir"
            ((FIXED++))
        fi
        return 1
    fi
    return 0
}

# Function to scan entire exams directory
scan_exams() {
    local exams_dir="${1:-./exams}"
    
    if [[ ! -d "$exams_dir" ]]; then
        error "Exams directory not found: $exams_dir"
        return 1
    fi
    
    info "Scanning $exams_dir..."
    echo
    
    # Find all PDF files and validate
    while IFS= read -r -d '' file; do
        validate_filename "$file" || true
    done < <(find "$exams_dir" -type f -name "*.pdf" -print0)
    
    echo
    
    # Check for README.md in each course directory
    info "Checking course README files..."
    echo
    
    while IFS= read -r -d '' course_dir; do
        check_course_readme "$course_dir" || true
    done < <(find "$exams_dir" -mindepth 1 -maxdepth 1 -type d -print0)
    
    echo
    
    return 0
}

# Function to generate README.md header
generate_readme_header() {
    cat <<'EOF'
<h3 align="center">SKIP – Past Exams Repository</h3>
<p align="center">
  <img align="center" src="docs/assets/skip-past-exams-poster.png"/>
</p><br>

Welcome to the official `GitHub` repository that gathers **examination
materials** for programmes at the former **IT Faculty** of [Gothenburg
University](https://www.gu.se/).

### What's Inside

Our repository currently features a sample of past exams, providing insights
into the types of assessments you can expect during your studies. These
materials are here to help you prepare effectively, understand the course
expectations, and excel in your academic journey.

## Interested in a particular course?

We're enabling students to **request** past exams for specific courses. If you
can't find the exam you're looking for, simply fill in the form below and we'll
do our best to provide you with the materials you need as soon as possible.
> $\to$ [**Request Past Exams**](https://forms.gle/DWeioA8dv16oHEsg7)

### Explore and Contribute

We are committed to adding old exams for the current study periods, ensuring
that you have access to the most up-to-date and relevant assessment materials
to support your learning.

Feel free to explore, **contribute** (see
[`CONTRIBUTING.md`](CONTRIBUTING.md)), and make the most of this repository as
you strive for excellence in your studies. Your feedback and contributions are
highly encouraged and appreciated!

## Programmes

Click to expand the list of courses for each programme.

EOF
}

# Function to load course data from JSON
get_course_data() {
    local course_code="$1"
    local courses_json="./descriptionCreator/data/courses.json"
    
    if [[ ! -f "$courses_json" ]]; then
        echo ""
        return 1
    fi
    
    # Use jq to extract course name and programmes
    jq -r --arg code "$course_code" '.[$code] // empty' "$courses_json" 2>/dev/null
}

# Function to get course name from JSON
get_course_name_from_json() {
    local course_code="$1"
    local courses_json="./descriptionCreator/data/courses.json"
    
    if [[ ! -f "$courses_json" ]]; then
        get_course_name "./exams/$course_code"
        return 0
    fi
    
    local name=$(jq -r --arg code "$course_code" '.[$code].name // empty' "$courses_json" 2>/dev/null)
    
    if [[ -n "$name" ]]; then
        echo "$name"
    else
        get_course_name "./exams/$course_code"
    fi
}

# Function to get courses for a programme from courses.json
get_programme_courses() {
    local prog_code="$1"
    local courses_json="./descriptionCreator/data/courses.json"
    
    jq -r --arg prog "$prog_code" '
        to_entries | 
        map(select(.value | type == "object" and (.programmes // [] | any(. == $prog)))) | 
        sort_by(.key) | 
        .[].key
    ' "$courses_json" 2>/dev/null
}

# Function to generate programme section with term ordering
generate_programme_with_terms() {
    local prog_code="$1"
    local prog_name="$2"
    local exams_dir="$3"
    local programme_orders_json="./descriptionCreator/data/programmeOrders.json"
    
    # Collect all course entries first to check if we have any
    local course_entries=""
    
    # Get terms/sections for this programme
    local term_count=$(jq --arg code "$prog_code" '.[$code] | length' "$programme_orders_json" 2>/dev/null)
    
    for ((i=0; i<term_count; i++)); do
        local term_name=$(jq -r --arg code "$prog_code" --argjson idx "$i" '.[$code][$idx].name // empty' "$programme_orders_json" 2>/dev/null)
        [[ -z "$term_name" ]] && continue
        
        local term_courses=""
        
        # Get courses for this term
        local courses=$(jq -r --arg code "$prog_code" --argjson idx "$i" '.[$code][$idx].courses[]? // empty' "$programme_orders_json" 2>/dev/null)
        
        while IFS= read -r course_code; do
            [[ -z "$course_code" ]] && continue
            
            local course_dir="$exams_dir/$course_code"
            
            # Check if course directory exists and has exams
            if [[ -d "$course_dir" ]]; then
                local exam_count=$(count_exams "$course_dir")
                
                # Only collect courses with at least 1 exam
                if [[ $exam_count -gt 0 ]]; then
                    local course_name=$(get_course_name_from_json "$course_code")
                    term_courses+="- [$course_code - $course_name](https://github.com/skipgu/past-exams/tree/main/exams/$course_code) ($exam_count exams)"$'\n'
                fi
            fi
        done <<< "$courses"
        
        # Only add this term if it has courses
        if [[ -n "$term_courses" ]]; then
            course_entries+="### $term_name"$'\n'$'\n'
            course_entries+="$term_courses"
            course_entries+=$'\n'
        fi
    done
    
    # Only output the programme section if there are any courses
    if [[ -n "$course_entries" ]]; then
        echo ""
        echo "<details>"
        echo "<summary><b>&#x1F447; $prog_code - $prog_name</b></summary>"
        echo ""
        echo -n "$course_entries"
        echo "***"
        echo ""
        echo "</details>"
    fi
}

# Function to generate programme section without term ordering
generate_programme_simple() {
    local prog_code="$1"
    local prog_name="$2"
    local exams_dir="$3"
    
    # Get courses for this programme from courses.json
    local courses=$(get_programme_courses "$prog_code")
    
    # Skip if no courses found in courses.json
    if [[ -z "$courses" ]]; then
        return 0
    fi
    
    # Collect course entries to check if we have any with exams
    local course_entries=""
    
    while IFS= read -r course_code; do
        [[ -z "$course_code" ]] && continue
        
        local course_dir="$exams_dir/$course_code"
        
        # Check if course directory exists and has exams
        if [[ -d "$course_dir" ]]; then
            local exam_count=$(count_exams "$course_dir")
            
            # Only collect courses with at least 1 exam
            if [[ $exam_count -gt 0 ]]; then
                local course_name=$(get_course_name_from_json "$course_code")
                course_entries+="- [$course_code - $course_name](https://github.com/skipgu/past-exams/tree/main/exams/$course_code) ($exam_count exams)"$'\n'
            fi
        fi
    done <<< "$courses"
    
    # Only output the programme section if there are courses with exams
    if [[ -n "$course_entries" ]]; then
        echo ""
        echo "<details>"
        echo "<summary><b>&#x1F447; $prog_code - $prog_name</b></summary>"
        echo ""
        echo -n "$course_entries"
        echo ""
        echo "***"
        echo ""
        echo "</details>"
    fi
}

# Function to generate programme sections for README
generate_programme_sections() {
    local exams_dir="${1:-./exams}"
    local programmes_json="./descriptionCreator/data/programmes.json"
    local programme_orders_json="./descriptionCreator/data/programmeOrders.json"
    local courses_json="./descriptionCreator/data/courses.json"
    
    # Check if JSON files exist
    if [[ ! -f "$programmes_json" ]] || [[ ! -f "$courses_json" ]]; then
        warning "JSON data files not found. Generating simple course list..."
        generate_simple_course_list "$exams_dir"
        return 0
    fi
    
    # Track which programmes have been processed
    declare -A processed_programmes
    
    # First, process programmes that have term ordering (in order of programmeOrders.json)
    if [[ -f "$programme_orders_json" ]]; then
        local ordered_programme_codes=$(jq -r 'keys[]' "$programme_orders_json" 2>/dev/null)
        
        while IFS= read -r prog_code; do
            [[ -z "$prog_code" ]] && continue
            
            # Get programme name
            local prog_name=$(jq -r --arg code "$prog_code" '.[$code].name // empty' "$programmes_json" 2>/dev/null)
            [[ -z "$prog_name" ]] && continue
            
            # Mark as processed
            processed_programmes["$prog_code"]=1
            
            # Generate programme section with term ordering
            generate_programme_with_terms "$prog_code" "$prog_name" "$exams_dir" || true
        done <<< "$ordered_programme_codes"
    fi
    
    # Then, process remaining programmes alphabetically (those without term ordering)
    local all_programme_codes=$(jq -r 'keys | sort[]' "$programmes_json" 2>/dev/null)
    
    while IFS= read -r prog_code; do
        [[ -z "$prog_code" ]] && continue
        
        # Skip if already processed
        [[ -n "${processed_programmes[$prog_code]:-}" ]] && continue
        
        # Get programme name
        local prog_name=$(jq -r --arg code "$prog_code" '.[$code].name // empty' "$programmes_json" 2>/dev/null)
        [[ -z "$prog_name" ]] && continue
        
        # Programme has no term ordering, list courses alphabetically
        generate_programme_simple "$prog_code" "$prog_name" "$exams_dir" || true
    done <<< "$all_programme_codes"
}

# Function to generate simple course list (fallback)
generate_simple_course_list() {
    local exams_dir="${1:-./exams}"
    
    echo ""
    echo "<details>"
    echo "<summary><b>&#x1F447; All Courses</b></summary>"
    echo ""
    echo "### Courses"
    echo ""
    
    # Get all course directories sorted
    local courses=()
    while IFS= read -r -d '' course_dir; do
        courses+=("$course_dir")
    done < <(find "$exams_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    
    # Generate course entries
    for course_dir in "${courses[@]}"; do
        local course_code=$(basename "$course_dir")
        local course_name=$(get_course_name "$course_dir")
        local exam_count=$(count_exams "$course_dir")
        
        echo "- [$course_code - $course_name](https://github.com/skipgu/past-exams/tree/main/exams/$course_code) ($exam_count exams)"
    done
    
    echo ""
    echo "***"
    echo ""
    echo "</details>"
}

# Function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        warning "jq is not installed. Install it for better README generation."
        warning "  macOS: brew install jq"
        warning "  Linux: sudo apt-get install jq or sudo yum install jq"
        return 1
    fi
    return 0
}

# Function to rebuild README.md
rebuild_readme() {
    local exams_dir="${1:-./exams}"
    local readme_file="./README.md"
    
    info "Rebuilding README.md..."
    
    if [[ ! -d "$exams_dir" ]]; then
        error "Exams directory not found: $exams_dir"
        return 1
    fi
    
    # Check for jq
    check_jq || warning "Falling back to simple course list..."
    
    # Backup existing README.md
    if [[ -f "$readme_file" ]]; then
        cp "$readme_file" "${readme_file}.backup"
        info "Backed up existing README.md to README.md.backup"
    fi
    
    # Generate new README.md
    {
        generate_readme_header
        generate_programme_sections "$exams_dir"
    } > "$readme_file"
    
    success "README.md has been rebuilt successfully"
    ((FIXED++))
    
    return 0
}

# Function to display summary
show_summary() {
    echo
    echo "═══════════════════════════════════════"
    echo "           VALIDATION SUMMARY"
    echo "═══════════════════════════════════════"
    
    if [[ $ERRORS -eq 0 ]]; then
        success "No errors found!"
    else
        error "$ERRORS error(s) found"
    fi
    
    [[ $WARNINGS -gt 0 ]] && warning "$WARNINGS warning(s) found"
    [[ $FIXED -gt 0 ]] && success "$FIXED item(s) fixed"
    
    echo "═══════════════════════════════════════"
    echo
    
    return $ERRORS
}

# Function to display usage
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Manage and validate past-exams repository structure and file naming.

OPTIONS:
    scan        Scan and validate all files in exams directory
    rebuild     Completely rebuild README.md from scratch
    help        Show this help message

EXAMPLES:
    $(basename "$0") scan
    $(basename "$0") rebuild

EOF
}

# Main script logic
main() {
    local command="${1:-help}"
    
    case "$command" in
        scan)
            scan_exams
            show_summary
            exit $?
            ;;
        rebuild)
            rebuild_readme
            show_summary
            exit $?
            ;;
        help|--help|-h)
            usage
            exit 0
            ;;
        *)
            error "Unknown command: $command"
            echo
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"