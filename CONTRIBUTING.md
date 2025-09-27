# Contributing to past-exams

Thank you for your interest in contributing! We welcome your help to continually expand and improve our collection of prior exams for the SEM, as well as other programs from CSE and Applied IT departments. Please read this file before contributing or write a SKIP board member.

Note: We recommend studying/observing repository conventions and a few of the more recent commit messages before contributing.

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

## Issues

## Commit Messages

## Pull Requests

---

Thank you for helping make this project better! Good luck!

\- SKIP Tech Team
