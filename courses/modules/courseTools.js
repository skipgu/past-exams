const fs = require("fs");


function stealCourseNames(courses) {
  trackedCourses = fs.readdirSync("./exams/", "utf-8");

  trackedCourses.forEach(course => {
    if (courses[course] == undefined && !fs.existsSync(`./exams/${course}/.gitignore`)) {
      let courseReadme = fs.readFileSync(`./exams/${course}/README.md`, "utf-8");
      courseReadme = courseReadme.split("\n")[0].split("-");
      courseReadme.shift();
      courses[course] = {"name": courseReadme.join("-").trim(), "credits": null, "level": null, "programmes": []};
    }
  });

  return courses;
}

function getCourseProgrammes(courses) {
  let programmes = {"NONE": []};

  for (const courseCode in courses) {
    const course = courses[courseCode];
    
    course.programmes.forEach(programme => {
      if (programmes[programme] == undefined) programmes[programme] = [];
      programmes[programme].push(courseCode);
    });
  }

  return programmes;
}

module.exports = { getCourseProgrammes, stealCourseNames };