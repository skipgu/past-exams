# Contributing to past-exams

Thank you for your interest in contributing! We welcome your help to continually expand and improve our collection of prior exams for the SEM, as well as other programs from CSE and Applied IT departments. Please read this file before contributing and/or write a SKIP board member.

Note: We recommend studying/observing repository conventions and a few of the more recent commit messages before contributing.

**_Only permitted users (by default SKIP Board Members; exceptions can be granted) can modify/delete/add new scripts/automatizatoins/new features or work on the main branch. All changes and PRs are reviewed by SKIP Board Members._**

## Reporting Issues & Questions

- Use [GitHub Issues](../../issues) to report mistakes or request new content.
- Include as much detail as possible: course, exam date, type of issue, etc.
- For any questions, open an issue or reach out to the SKIP Board Members/maintainers.

## Expected structure of the repository

The following is the expected structure of this **monorepo** that compiles the prior exams at the former IT faculty of Gothenburg University.

```txt
.
├─ exams
│   ├── courseCode                                        # exam course code
│   │   ├── date                                          # date of the exam (format YYYY-MM-DD, if day is unknown - 99)
│   │   │   ├── Exam-courseCodes-YYMMDD.pdf               # exams
│   │   │   ├── Answer-courseCode-YYMMDD-anonymCode.pdf   # student answers - with annonymCode
│   │   │   ├── Answer-courseCode-YYMMDD-official.pdf     # teacher answers - code official or official_partial
│   │   │   ├── Combined-courseCode-YYMMDD-official.pdf   # teacher answers - code official or official_partial
│   │   │   └── Combined-courseCode-YYMMDD-anonymCode.pdf # exams with student answers
│   │   ├── final_report-courseCode-id-grade              # final repots
│   │   ├── ...                                           # other exams (NOT COUNTED)
│   │   └── README.md                                     # overview for the course
│   └── ...                                               # other courses
└── README.md
```

### Examples of files
```txt
Exams:
- Exam-DIT009-241030.pdf
- Exam-DIT032_DIT033_DAT335-220817.pdf          # A course with multiple courseCodes

Answers:
- Answer-DIT009-241030-official.pdf             # An official answer by the Examiner/Course Responsible
- Answer-DIT043-220103-673.pdf                  # An answer with student annonymCode 673
- Answer-DIT431-231027-DIT431_0007_ADT.pdf      # An answer with full format annonymCode DIT431_0007_ADT

Combined:
- Combined-DIT633-230316-DIT633-0030-YTW.pdf    # A Combined Exam & Student Answer
- Combined-DIT044-250317-official_partial.pdf   # A Combined Exam & partial Answers by the Examiner/Course Responsible
- Combined-DIT821-211027-official.pdf           # A Combined Exam & Answer by the Examiner/Course Responsible

Final Reports:
- final_report-DIT347-009-VG.pdf                # A student final report with grade VG
- final_report-DIT347-008-G.pdf                 # A student final report with grade G
```

## How to Contribute

1. **Create an issue** with proper title and if needed, the desription.
2. **Create a new branch** for your changes from the issue.
3. **Clone the repository** and checkout to your branch.
4. **Commit your changes**, with proper commit message.
5. **Wait for the actions to run** to ensure nothing is broken.
6. **Open a pull request** with a clear title, description & labels.

## Issues - Conventions

Before starting a new issue, check whether there isn't an opened issue with similar aim/feature/problem - if unsure, contact us.
1. Use a Clear and Short Descriptive Title in the present tense
  - Start in a verbs in present tense
  - If you are adding some exams for a single course, mention it in the title, if a single exam, mention it in the title
    - Add DIT009 Exams 2024
    - Add DIT008 August 2025 Exam
  - If you are adding exams in bulk, try to make the title unique (to avoid having "Add first-year exma" issues multiple times)- add a month/date (if multiple bulk upload issues in the same month) of upload
    - Add first-year exams 12-2024
    - Upload SEM exams 9-2025
    - Add answers 9-2025
2. Provide Relevant Details in the Body (Optional)
  - If your issue is about a specific file, include a direct link to it.
  - Describe the problem, suggestion, or question clearly.
  - If you have a proposed solution, mention it.
  - If reporting a bug, describe how to reproduce it if possible.
  - If requesting a feature, explain the use-case or motivation.
  - **Example:**
   ```txt
    Title: Fix DIT 636 2024-03-13 exam paper not opening
    Description: Link to the exam file: [Exam PDF](https://github.com/skipgu/past-exams/blob/main/exams/DIT636/2024-03-13/Exam-DIT636-240313.pdf)
   ```
3. Use Labels to Categorize Your Issue
  - Apply relevant labels such as:
  - This helps maintainers triage and prioritize issues.
4. Assign and Mention Collaborators (Optional)
  - If you want a specific person to look at the issue, mention them.
  - Assign the issue if you have the necessary permissions.

## Branches - Conventions
1. Create a new branch from the issue
2. A branch shall start wit the pre-generated number
3. Keep the name of the branch close/identical to the name of the issue

### General Tips
- **Lowercase only:** Use lowercase letters for all branch names.
- **No spaces:** Use hyphens (`-`) instead of spaces.
- **Be descriptive:** The branch name should make it clear what the branch is for.
- **Keep it short:** Try to keep branch names concise, but not at the expense of clarity - they should be close to identical to the title of the issue.

Examples
- 32-add-contributing-md
- 42-fix-breaking-pipeline

## Commit Messages - Conventions

## Pull Requests - Conventions

---

Thank you for helping make this project better! Good luck!

\- SKIP Tech Team
