const fs = require("fs");

// Replace {{variable}}s
function replaceVariables(originalString, data) {
  return originalString.replace(/\{\{(\w+)\}\}/g, function (variable, variableName) {
    if (data.hasOwnProperty(variableName)) {
      return data[variableName];
    } else {
      return variable;
    }
  });
}

// Create the markdown section for each programme.
function getProgrammeMDs(programmes, courses, courseProgrammes) {
  const programmeSource = fs.readFileSync("./courses/static/programme.md", "utf-8"); // The skeleton of the md.

  let programmeMDs = {};

  let coursesInProgrammes = []

  for (const programmeCode in courseProgrammes) {
    const programme = programmes[programmeCode];
    if (programme === undefined) continue; // If the programme is not tracked (e.g. Not from the IT Faculty) then skips

    let courseList = courseProgrammes[programmeCode];
    courseList = courseList.filter(course => fs.existsSync(`./exams/${course}`)); // Only tracks courses that have their directories

    coursesInProgrammes = coursesInProgrammes.concat(courseList);

    const stuctureFilePath = `./courses/programmeOrders/${programmeCode}.json`; // The programme's structure

    let sectionStrings = [];

    // Check for defined terms
    if (fs.existsSync(stuctureFilePath)) {
      const programmeOrderRaw = fs.readFileSync(stuctureFilePath, "utf-8");
      const programmeOrder = JSON.parse(programmeOrderRaw);

      let processedCourses = []; // To keep track of processed courses

      Object.keys(programmeOrder).forEach(term => {
        let termCoursesStrings = [];
        programmeOrder[term].forEach(course => {
          if (courseList.includes(course) && fs.existsSync(`./exams/${course}`)) {
            termCoursesStrings.push(`- [${course} - ${courses[course].name}](/exams/${course})\n`);
            processedCourses.push(course); // Mark course as processed
          }
        });

        if (termCoursesStrings.length > 0) {
          sectionStrings.push(`### ${term}:\n\n${termCoursesStrings.join('')}`);
        }
      });

      // Process courses not in any terms
      const unlistedCourses = courseList.filter(course => !processedCourses.includes(course)).sort();
      if (unlistedCourses.length > 0) {
        let unlistedCoursesString = unlistedCourses.map(course => `- [${course} - ${courses[course].name}](/exams/${course})\n`).join('');
        sectionStrings.push(`### Not in any terms:\n\n${unlistedCoursesString}`);
      }
    } else {
      // File doesn't exist
      courseList = courseList.sort();
      if (courseList.length > 0) {
        let coursesString = courseList.map(course => `- [${course} - ${courses[course].name}](/exams/${course})\n`).join('');
        sectionStrings.push(coursesString);
      }
    }

    // Join all sections with `***` only if more than one section exists
    let programmeCourses = sectionStrings.length > 1 ? sectionStrings.join("\n***\n\n") : sectionStrings.join("");

    if (programmeCourses) {
      const programmeMD = replaceVariables(programmeSource, {
        "programmeCode": programmeCode,
        "programmeName": programme.name,
        "courses": programmeCourses
      });

      programmeMDs[programmeCode] = `\n${programmeMD}`;
    }
  }

  return [programmeMDs, coursesInProgrammes];
}

function getNoneMD(courses, courseProgrammes) {
  const programmeSource = fs.readFileSync("./courses/static/programme.md", "utf-8"); // The skeleton of the md.

  let trackedProgrammlessCourses = [];
  for (const course in courses) {
    if (!courseProgrammes.includes(course) && fs.existsSync(`./exams/${course}`)) trackedProgrammlessCourses.push(course);
  }

  if (trackedProgrammlessCourses.length == 0) return "";

  let programmeCourses = "";

  trackedProgrammlessCourses.forEach(courseCode => {
    const course = courses[courseCode];
    programmeCourses += `- [${courseCode} - ${course.name}](/exams/${courseCode})\n`;
  });

  const NoneMD = replaceVariables(programmeSource, {
    "programmeCode": "NONE",
    "programmeName": "Courses that have yet to be assigned to any programmes",
    "courses": programmeCourses
  });

  return NoneMD;
}

// Sort all programme markdowns based and also apply priority.
function sortProgrammeMDs(programmeMDs, priorityProgrammes) {
  const allProgrammes = Object.keys(programmeMDs);
  const prioritized = [], others = [];

  allProgrammes.forEach(key => {
    if (priorityProgrammes.includes(key)) {
      prioritized.push(key);
    } else {
      others.push(key);
    }
  });

  others.sort();

  return [...prioritized, ...others];
}

module.exports = { sortProgrammeMDs, getProgrammeMDs, getNoneMD};