const fs = require("fs");
const programmeMD = require("./modules/programmeMD");
const courseTools = require("./modules/courseTools");

const programmes = require("./programmes.json");
let courses = require("./courses.json");

const priorityProgrammes = ["N1SOF", "N2SOF"];


function main() {
  const courseProgrammes = courseTools.getCourseProgrammes(courses);

  courses = courseTools.stealCourseNames(courses);

  let readme = fs.readFileSync("./courses/static/header.md", "utf-8");

  const [programmeMDs, coursesInProgrammes] = programmeMD.getProgrammeMDs(programmes, courses, courseProgrammes)

  let orderedProgrammeMDs = programmeMD.sortProgrammeMDs(programmeMDs, priorityProgrammes);

  orderedProgrammeMDs.forEach(programmeCode => {
    readme += programmeMDs[programmeCode]
  });

  readme += programmeMD.getNoneMD(courses, coursesInProgrammes);

  fs.writeFileSync("./README.md", readme, "utf-8");
}

main();