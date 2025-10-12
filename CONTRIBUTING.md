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

## What to Update with addition of a new Exam/Course/Programme

### Adding an Exam

- After adding an exam/answer, please add more info about it to the Course's README FILE. 
- Update Courses' exam count on repo's [README.md](README.md).
- Update Courses' exam count on repo's [exams.json](exams.json).

### Adding a Course

- Add a README.md file to the Course's folder
    - A template of the Course's README.md file (Do not forget to fill out the course Code and Name in the README.md):

```txt
## courseCode - courseName
Welcome to the courseCode - courseName, where we've compiled past exams and student answers to assist in your preparation for this course.

Here’s what we have so far:

|    Date    | Questions | Answers |   Notes   |
|------------|-----------|---------|-----------|
| YYYY-MM-DD | Yes       | Yes     |           |
```
- If it is a part of a program that is on the repo's [README.md](README.md), add it to the correct place (courses are usually ordered by terms/study periods they are in, in a given programme) and program. Indicate whether it is a course that is not being taught with prefix: `**_OLD_** - `
    - Example `**_OLD_** - [DIT348 - Software Development Methodologies](https://github.com/skipgu/past-exams/tree/main/exams/DIT348) 10 exams.` 
- Add the course to repo's [exams.json](exams.json) in the same order (courses are usually ordered by terms/study periods they are in, in a given programme) and correct programme as it is on the repo's [README.md](README.md).
      - A template of the json block
```json
{
  "courseCode": "",
  "courseName": "",
  "courseCredit": 7.5,
  "courseLevel": "",
  "courseExamCount": 30,
  "courseDirectory": "./exams/courseCode"
},
```
- Add the course to [descriptionCreator/data](descriptionCreator/data/), specifically:
    - Add it to [courses.json](descriptionCreator/data/courses.json)
        - Template:
          ```json
          "courseCode": {
                "name": "",
                "credits": 7.5,
                "level": "",
                "programmes": ["courseCode"]
          },
          ```
    - Add it to the [programmeOrders.json](descriptionCreator/data/programmeOrders.json) in the correct order (courses are usually ordered by terms/study periods they are in, in a given programme) in all the programmes that the course is in.

### Adding a Programme

- Add the programme to the repo's [README.md](README.md), any additional programme needs to be added after the biggest programmes whose exams we have on the repo.
    - Template:
    ```txt
    <details>
    <summary><b>&#x1F447; programmeCode - Full Programme name</b></summary>
    
    ### 
    
    - [courseCode - Full Course Name](https://github.com/skipgu/past-exams/tree/main/exams/courseCode) x exams.
    
    - [courseCode - Full Course Name](https://github.com/skipgu/past-exams/tree/main/exams/courseCode) x exams.
    
    
    ***
    
    </details>
    ```
- Add the programme to descriptionCreator's [programmes.json](descriptionCreator/data/programmes.json)
    - Template:
      ```json
      "programmeCode": {
        "name": "",
        "language": "en/se"
      },
      ```
- If a programme is getting more than one course and across multiple terms, it is need to add it to [programmeOrders.json](descriptionCreator/data/programmeOrders.json)
    - Template:
    ```
    "programmeCode": [
        {
          "name": "Term 1 - Year 1",
          "courses": [
            "courseCode",
            "courseCode"
          ]
        },
        {
          "name": "Term 2 - Year 1",
          "courses": [
            "courseCode",
            "courseCode"
          ]
        },
    ]
    ```

## How to Contribute

1. **Create an issue** with proper title and if needed, the description.
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

1. Create a PR with appropriate name, ideally close or identical to that of the issue.
2. Choose the correct branch to the PR
3. Write a short description of what has been added (e.g. which exams, solutions...)
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
