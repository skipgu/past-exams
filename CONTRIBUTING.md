# Contributing to past-exams

Thank you for your interest in contributing! We welcome your help to continually expand and improve our collection of prior exams for the SEM, as well as other programs from CSE and Applied IT departments. Please read this file before contributing and/or write a SKIP board member.

**_Only permitted users (by default SKIP Board Members; exceptions can be granted) can modify/delete/add new scripts/automatizatoins/new features or work on the main branch. All changes and PRs are reviewed by SKIP Board Members._**

Please, follow the set conventions & rules to ensure clear **traceability**.

## Reporting Issues & Questions

- Use [GitHub Issues](../../issues) to report mistakes or request new content.
- Include as much detail as possible: course, exam date, type of issue, etc.
- For any questions, open an issue or reach out to the SKIP Board Members/maintainers.

## Expected structure of the repository

The following is the expected structure of this **monorepo** that compiles prior exams.

```txt
.
├─ exams
│   ├── courseCode                                        # exam course code
│   │   ├── date                                          # date of the exam (format YYYY-MM-DD, if day is unknown - 99)
│   │   │   ├── Exam-courseCodes-YYMMDD.pdf               # exams
│   │   │   ├── Answer-courseCode-YYMMDD-anonymCode.pdf   # (student) answers - with annonymCode or practice (usually from examiner)
│   │   │   ├── Answer-courseCode-YYMMDD-official.pdf     # teacher answers - code official or official_partial
│   │   │   ├── Combined-courseCode-YYMMDD-official.pdf   # teacher answers - code official, official_partial or practice
│   │   │   └── Combined-courseCode-YYMMDD-anonymCode.pdf # exams with student answers
│   │   ├── final_report-courseCode-id-grade              # final reports
│   │   ├── ...                                           # other exams (NOT COUNTED)
│   │   └── README.md                                     # overview for the course
│   └── ...                                               # other courses
└── README.md
```

### Examples of files
```txt
Exams:
- Exam-DIT009-241030.pdf

Answers:
- Answer-DIT009-241030-official.pdf             # An official answer by the Examiner/Course Responsible
- Answer-DIT043-220103-673.pdf                  # An answer with student annonymCode 673
- Answer-DIT431-231027-0007_ADT.pdf             # An answer with full format annonymCode 0007_ADT

Combined:
- Combined-DIT633-230316-0030-YTW.pdf           # A Combined Exam & Student Answer
- Combined-DIT044-250317-official_partial.pdf   # A Combined Exam & partial Answers by the Examiner/Course Responsible
- Combined-DIT821-211027-official.pdf           # A Combined Exam & Answer by the Examiner/Course Responsible
- Combined-DIT636-230399-practice.pdf           # A Combined Practice Exam & Answer by the Examiner/Course Responsible

Final Reports:
- final_report-DIT347-009-VG.pdf                # A student final report with grade VG
- final_report-DIT347-008-G.pdf                 # A student final report with grade G
```

## How to Contribute (in a Nutshell)

**We want to make contributing as easy as possible; just ensure to drop in the files in the right location with the expected filename format**. You can follow this checklist:
1. **Create an issue** with proper title and if needed, the description.
2. **Create a new branch** for your changes from the issue (alt. *fork* the repository.)
3. **Clone the repository** and checkout to your branch.
4. **Commit your changes**, with proper commit message.
5. *(optional)* **Run our automatization script** to ensure the data is correctly added, counted and formatted.
6. **Open a pull request** with a clear title, description & labels.
7. **Wait for the actions to run** to ensure nothing is broken.
8. **Wait for an approval & merge**, a member from SKIP team will assist you prior to merging to mainline.

## What to Update with addition of a new Exam/Course/Programme

We provide a script that verifies that any new file added obeys the expected structure. See [`SCRIPT_USAGE.md`](./SCRIPT_USAGE). You can run the script locally after adding new **examination files** (requires an installation of `jq`, a common JSON processor) or inspect the script when run on your PR (as an action). Either way, only a non-failing PR(s) will be merged.

### Adding a Course

If the course doesn't exists in [`courses.json`](./data/courses.json), add a new entry in the form, e.g.:
```json
"DIT023": {
  "name": "Mathematical Foundations for Software Engineering",
  "credits": 7.5,
  "level": "bachelor",
  "discontinued": true,
  "programmes": ["N1SOF"]
}
```
> [!NOTE]
> Courses labeled with `discontinued: true` will be displayed with a prefix `**_OLD_**` in [`README.md`](./README.md). Also see [`programmes.json`](./data/programmes.json) with available programme options.

### Specific Study Period

It is encouraged to provide information about the study period when the course takes place; for this, we have a file [`programmeOrders.json`](./data/programmeOrders.json). We typically group courses by a semester (i.e., two consecutive study period) - these will be distinguished from the other courses in [`README.md`](./README.md). For instance:
```json
"N1SOF": [
    {
      "name": "Year 1: SP1 & SP2",
      "courses": [
        "DIT008",
      ]
    },
    {
      "name": "Year 1: SP3 & SP4",
      "courses": [
        "DIT047",
      ]
    },
]
```

### Adding a Programme

If the programme doesn't exist in [`programmes.json`](./data/programmes.json), add a new entry in the form, e.g.:
```json
"N1SOF": {
  "name": "Software Engineering and Management Bachelor's Programme",
  "language": "en"
}
```

> [!IMPORTANT]
> The file [`README.md`](./README.md) is auto-generated by our script so you don't need to update it manually.

*(the following is non-essential to the expected structure of the monorepo __but__ provides guidelines on how we use `git` workflow; which we expect to be followed when contributing)*

***

## Issues - Conventions

Before starting a new issue, check whether there isn't an opened issue with similar aim/feature/problem - if unsure, contact us.
1. Use a Clear and Short Descriptive Title in the present tense
    - Start in a verbs in present tense
    - If you are adding some exams for a single course, mention it in the title, if a single exam, mention it in the title
      - `Add DIT009 Exams 2024`
      - `Add DIT008 August 2025 Exam`
    - If you are adding exams in bulk, try to make the title unique (to avoid having "Add first-year exam" issues multiple times)- add a month/date (if multiple bulk upload issues in the same month) of upload
      - `Add first-year exams 12-2024`
      - `Upload SEM exams 9-2025`
      - `Add answers 9-2025`
2. Provide Relevant Details in the Body (Optional)
    - If your issue is about a specific file, include a direct link to it.
    - Describe the problem, suggestion, or question clearly.
    - If you have a proposed solution, mention it.
    - If reporting a bug, describe how to reproduce it if possible.
    - If requesting a feature, explain the use-case or motivation.
    - **Example:**
```txt
Title:
Fix DIT 636 2024-03-13 exam paper not opening
Description:
Link to the exam file: [Exam PDF](https://github.com/skipgu/past-exams/blob/main/exams/DIT636/2024-03-13/Exam-DIT636-240313.pdf)
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

**Examples**
- `32-add-contributing-md`
- `42-fix-breaking-pipeline`

## Commit Messages - Conventions

- Keep commit messages concise but descriptive.
- Reference related issues at the end of the message (e.g., `(#44)` )
- If multiple authors were present, do not forget to Co-Author them (TBA)
- Use [Conventional Commits](https://www.conventionalcommits.org/) format:
  - `docs:` for documentation/new exams/changes in readme-s (e.g., `docs: add DIT044 03-2025 re-exam (#44)` )
  - `feat:` for new functionalities
  - `fix:` for bug fixes (e.g., `fix: update deploy job to install required artifacts` )
  - ...
- If needed, you can add a commit message description

**Examples**
- `docs: add issues and branches conventions (#32)`
- `fix: recount exams data (#46)`

**Notes**

It is possible to change the commit message after committing. Read more on [how here](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/changing-a-commit-message).

Read more about Co-Authoring [here](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors).


## Pull Requests (PRs) - Conventions

### Creating Pull Requests

1. Create a PR with appropriate name, ideally close or identical to that of the issue. A number of the issue can be mentioned in brackets.
    - E.g.: "Add Contributing Guidelines (#32)"
2. Choose the correct branch to the PR
3. Write a short description of what has been added (e.g. which exams, solutions, mention which issues will be closed and which other are related...)
4. Choose an appropriate label, assign yourself to Assigners
5. Request a review from one of these active maintainers - @tomiz87, @bimnett, @rawan-abid, or @michalspano (Or Contact us on the SKIP Discord Server)

If PR passes through by a reviewer - nothing left to do, the reviewer oversees the rest

If changes are needed - commit them and resolve/add comments, request review again

### Reviewing Pull Requests 

- The reviewer should review and leave descriptive feedback if needed (changes can still be recommended).
- If the reviewer finds the issue as done (the code and documentation needs no further changes):
  - The reviewer should write a comment approving the PR (for example `LGTM`) and approve the PULL request.
  - The reviewer merges the branch and deletes the merged branch.
- If the reviewer finds the issue needs improvement:
  - The reviewer should comment what specifically should be improved and if needed, get in contact with the person responsible.

- **Merge conflict:** The reviewer should contact the developer who was responsible for the conflicting part of the PR, and resolve it together.

---

Thank you for helping make this project better! Good luck!

\- SKIP Tech Team
