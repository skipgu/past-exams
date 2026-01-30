#!/usr/bin/env bash
# A user-friendly, light-weight script written in Bash that checks the structure
# of the mono-repo. Run as:
# $ ./manage-exams.sh help

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

WEB_MODE=0 # global flag to use absolute link prefix for files (default: off)

# Function to print colored messages
error() { echo -e "${RED}✗ ERROR: $1${NC}" >&2; ((ERRORS++)); }
warning() { echo -e "${YELLOW}⚠ WARNING: $1${NC}"; ((WARNINGS++)); }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${BLUE}ℹ $1${NC}"; }

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
    
    # Extract date from path (format: YYYY-MM-DD), only for non-report files
    if [[ "$basename" != *"report"* ]] then
        local date_dir=$(basename "$dirname")
        if [[ ! "$date_dir" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            warning "File in invalid date directory: $file (expected YYYY-MM-DD format)"
            return 1
        fi
    fi
    
    # - A student (anonymous) code is of the format: `NNNN` or `NNNN_CCC` where N is
    # digit and C letter; the course code prefix is removed for simplicify (it adds
    # no information to students; the course code is visible already).
    # - A course code is of the form CCCNNN or CCCNNN_CCCNNN if there's an
    # alternative course code name (e.g. DIT045_DAT355).
    case "$basename" in
        Exam-*.pdf)
            if [[ ! "$basename" =~ ^Exam-(practice-)?[A-Z]{3}[0-9]{3}(_[A-Z]{3}[0-9]{3})*-[0-9]{6}\.pdf$ ]]; then
                error "Invalid exam filename: $basename (expected Exam-(practice-)CourseCode-YYMMDD.pdf)"
                return 1
            fi
            ;;
        Answer-*.pdf)
            if [[ ! "$basename" =~ ^Answer-[A-Z]{3}[0-9]{3}(_[A-Z]{3}[0-9]{3})*-[0-9]{6}-(official|official_partial|[0-9]{4}|[0-9]{4}_[A-Z]{3})\.pdf$ ]]; then
                error "Invalid answer filename: $basename (expected Answer-CourseCode-YYMMDD-{official|official_partial|code}.pdf)"
                return 1
            fi
            ;;
        Combined-*.pdf)
            if [[ ! "$basename" =~ ^Combined-[A-Z]{3}[0-9]{3}(_[A-Z]{3}[0-9]{3})*-[0-9]{6}-(official|official_partial|practice|[0-9]{3}|[0-9]{3}_[A-Z]{3})\.pdf$ ]]; then
                error "Invalid combined filename: $basename (expected Combined-CourseCode-YYMMDD-{official|official_partial|practice|code}.pdf)"
                return 1
            fi
            ;;
        final_report-*.pdf)
            if [[ ! "$basename" =~ ^final_report-[A-Z]{3}[0-9]{3}(_[A-Z]{3}[0-9]{3})*-[0-9]+-[A-Z]+\.pdf$ ]]; then
                error "Invalid final report filename: $basename (expected final_report-CourseCode-id-GRADE.pdf)"
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

    # Ensure course_dir starts with ./
    if [[ ! "$course_dir" =~ ^\. ]]; then
        course_dir="./$course_dir"
    fi

    # Skip the test for the submodule DIT182 (corner case)
    if [[ "$course_dir" == *DIT182* ]]; then
        info "Skipping README.md check for $course_dir (matched DIT182)"
        return 0
    fi

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

generate_readme_header() {
    cat ./static/header.md
}

# Function to load course data from JSON
get_course_data() {
    local course_code="$1"
    local courses_json="./data/courses.json"
    
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
    local courses_json="./data/courses.json"
    
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
    local courses_json="./data/courses.json"
    
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
    local programme_orders_json="./data/programmeOrders.json"

    # For web, use permalink prefix to repo; otherwise, use local (file) link
    local link="./exams"
    if [[ $WEB_MODE -gt 0 ]]; then link="$REPO_PERMALINK_DOCS"; fi
    
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
                    local is_discontinued=$(jq -r --arg code "$course_code" '.[$code].discontinued // false' "./data/courses.json" 2>/dev/null)
                    local old_prefix=""
                    if [[ "$is_discontinued" == "true" ]]; then
                        old_prefix="**_OLD_** "
                    fi
                    term_courses+="- ${old_prefix}[$course_code - $course_name]($link/$course_code) ($exam_count exams)"$'\n'
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

REPO_PERMALINK_DOCS="https://github.com/skipgu/past-exams/tree/main/exams"

# Function to generate programme section without term ordering
generate_programme_simple() {
    local prog_code="$1"
    local prog_name="$2"
    local exams_dir="$3"

    # For web, use permalink prefix to repo; otherwise, use local (file) link
    local link="./exams"
    if [[ $WEB_MODE -gt 0 ]]; then link="$REPO_PERMALINK_DOCS"; fi
    
    # Get courses for this programme from courses.json
    local courses=$(get_programme_courses "$prog_code")
    
    # Skip if no courses found in courses.json
    if [[ -z "$courses" ]]; then
        return 0
    fi
    
    # Collect course entries to check if we have any with exams
    local course_entries=""
    
    while IFS= read -r course_code; do
        local course_dir="$exams_dir/$course_code"
        
        # Check if course directory exists and has exams
        if [[ -d "$course_dir" ]]; then
            local exam_count=$(count_exams "$course_dir")
            
            # Only collect courses with at least 1 exam
            if [[ $exam_count -gt 0 ]]; then
                local course_name=$(get_course_name_from_json "$course_code")
                local is_discontinued=$(jq -r --arg code "$course_code" '.[$code].discontinued // false' "./data/courses.json" 2>/dev/null)
                local old_prefix=""
                if [[ "$is_discontinued" == "true" ]]; then
                    old_prefix="**_OLD_** "
                fi
                course_entries+="- ${old_prefix}[$course_code - $course_name]($link/$course_code) ($exam_count exams)"$'\n'
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
    local programmes_json="./data/programmes.json"
    local programme_orders_json="./data/programmeOrders.json"
    local courses_json="./data/courses.json"
    
    # Check if JSON files exist
    if [[ ! -f "$programmes_json" ]] || [[ ! -f "$courses_json" ]]; then
        warning "JSON data files not found. Generating simple course list..."
        generate_simple_course_list "$exams_dir"
        return 0
    fi
    
    # Track which programmes have been processed
    declare -A processed_programmes
    
    # First, process programmes that have term ordering
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
        
        echo "- [$course_code - $course_name](./$course_code) ($exam_count exams)"
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

    # For web, use a different markdown file (so that they don't clash)
    local readme_file="./exams"
    if [[ $WEB_MODE -gt 0 ]]; then readme_file="README.web.md"; fi
    
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
    web         Completely rebuild README.md from scratch with GitHub permalink prefix for web
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
        web)
            WEB_MODE=1
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
