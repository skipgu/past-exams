# Description Creator

This program creates the description for the past exams repo of SKIP

To run this program use the command `npm run createDescription`!

# Static files
The static files follow a strict format in order to build the proper markdown file in the end.

The main file is the `structure.md` file, this defines how everything is to be chained together.

The program understands variables and markdown file references. Both ust be defined between double curly brackets.
If there are multiple markdown files of the same name that needs to be chained together than it should be refferred to as `.mds`. During these the program will import the variable named the same + an `s` character into data so they can be referred to as variables

for example if you say `programme.mds` then the variables under `programmes` will be available in data (if previous variables don't confict with the current variable, they'll still be available too.) 

## Variables
```
"programmes":
  "programmeCode", "prorammeName":, "language", "terms":
    "termName", "courses":
      "courseCode", "courseName", "courseCredit", "courseLevel", "courseDirectory", "courseExamCount"
```

# Settings
The following settings can be set currently.
- priorityProgrammes - Ordered list of programmes that should be prioritized
- extraCourses - List the courses that are not in any programmes
- emptyCourses - List courses that are defined and have no exams
- extraProgrammes - List programmes that are not defined
- emptyProgrammes - List programmes without courses
- termifyProgrammes - Split courses by terms if the programme terms are defined