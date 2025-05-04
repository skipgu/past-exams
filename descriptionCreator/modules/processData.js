import * as fs from 'fs';

import courses from "../data/courses.json" assert {type: "json"};
import programmes from "../data/programmes.json" assert {type: "json"};
import programmeOrders from "../data/programmeOrders.json" assert {type: "json"};

// List courses that are defined and have no exams
function checkEmptyCourses(settings) {
  for (const course in courses) {
    if (!fs.existsSync(`./exams/${course}`)) {
      delete courses[course];
    }
  }
}

// List the courses that are not in any programmes
function checkExtraCourses(settings) {
  const courseList = fs.readdirSync("./exams/");
  for (const course of courseList) {
    if (!courses[course]) {
      if (fs.existsSync(`./exams/${course}/README.md`)) {
        const courseDescription = fs.readFileSync(`./exams/${course}/README.md`).toString();

        const regexPattern = new RegExp(`${course} - (\\p{L}((\\p{L}| )*\\p{L}))`, "u");

        const match = courseDescription.match(regexPattern);
        const courseName = match ? match[1] : "Unkown course";
        courses[course] = { name: courseName, credits: null, level: null, programmes: [] };
      }
    }
  }
}

function countExams(settings) {
  for (const course in courses) {
    if (fs.existsSync(`./exams/${course}`)) {
      const examDirectoryContent = fs.readdirSync(`./exams/${course}`, { withFileTypes: true });

    const examCount = examDirectoryContent.filter(content => content.isDirectory() && /^\d{4}-\d{2}-\d{2}$/.test(content.name)).length + examDirectoryContent.filter(content => content.isFile() && /^final_report-[a-zA-Z0-9]{6}-/.test(content.name)).length;


      courses[course].exams = examCount;
    } else {
      courses[course].exams = 0;
    }
  }
}

function populateProgrammes(settings) {
  for (const programme in programmeOrders) {
    if (!programmes[programme]) {
      programmes[programme] = {name: null, language: null};
    }
    programmes[programme].courses = [];
    for (const term in programmeOrders[programme]) {
      programmeOrders[programme][term].courses = programmeOrders[programme][term].courses.filter(course => courses[course]);

      programmeOrders[programme][term].courses.forEach(course => { programmes[programme].courses.push(course); });

      if (programmeOrders[programme][term].courses.length == 0) {
        delete programmeOrders[programme][term];
      }
    }
  }
  for (const course in courses) {
    for (const programme of courses[course].programmes) {
      if (!programmes[programme]) {programmes[programme] = {name: null, la5nguage: null}}
      if (!programmes[programme].courses) {programmes[programme].courses = []}
      if (!programmes[programme].courses.includes(course)) {
        if (!programmeOrders[programme]) { programmeOrders[programme] = []; }
        const terms = programmeOrders[programme].map(term => term.name);
        if (!terms.includes("")) {programmeOrders[programme].push({"name": "", courses: []})}
        programmeOrders[programme] = [...programmeOrders[programme]].filter(item => item);
        const term = programmeOrders[programme].findIndex(term => term.name == "");
        programmeOrders[programme][term].courses.push(course);
        programmes[programme].courses.push(course);
      }
    }
  }
}

function checkExtraProgrammes(settings) {
  for (const programme in programmes) {
    if (!programmes[programme].name) {
      delete programmes[programme];
    }
  }
}

function checkForEmptyProgrammes(settings) {
  for (const programme in programmes) {
    if (!programmes[programme].courses) {
      delete programmes[programme];
    }
  }
}

function checkEmptyProgrammes(settings) {
  const priority = settings.priorityProgrammes;
  priority.forEach(programme => {
    if (!programmes[programme]) programmes[programme] = {name: null, language: null, courses: [], terms: []}; 
  });
}

const orderedProgrammes = [];
function orderProgrammes(settings) {
  const priority = settings.priorityProgrammes;
  priority.forEach(programme => {
    if (programmes[programme]) { orderedProgrammes.push({programmeCode: programme, ...programmes[programme]}); }
  });
  
  const remaining = Object.keys(programmes).filter(programme => !priority.includes(programme) && programme != "NONE").sort();
  remaining.forEach(programme => {
    orderedProgrammes.push({programmeCode: programme, ...programmes[programme]});
  });

  if (settings.extraCourses && programmes.NONE) {
    orderedProgrammes.push({programmeCode: "NONE", ...programmes.NONE});
  }
  
  orderedProgrammes.forEach(programme => {
    programme.terms = programmeOrders[programme.programmeCode];
  });
}

function checkProgrammelessCourses(settings) {
  const courseArrays = Object.values(programmes).map(programme => programme.courses);
  
  const inProgramme = courseArrays.reduce((allCourses, currentCourses) => {
    return allCourses.concat(currentCourses);
  }, []);

  for (const course in courses) {
    if (!inProgramme.includes(course)) {
      if (!programmes.NONE) { programmes.NONE = {name: `${settings.courseNotAssigned}`, language: null, courses: []}; }
      programmes.NONE.courses.push(course);
    }
  }
  if (settings.extraCourses && programmes.NONE) {
    programmeOrders.NONE = [{name: "", courses: programmes.NONE.courses}]
  }
}

function putInCourses(settings) {
  orderedProgrammes.forEach(programme => {
    if (programme.terms != undefined) {
      programme.terms.forEach(term => {
        term.courses = term.courses.map(course => [course, courses[course]]);
      });
    }
  });
}

export function processData(settings) {
  delete courses.$schema;
  delete programmes.$schema;
  delete programmeOrders.$schema;

  if (!settings.emptyCourses) { checkEmptyCourses(settings); }
  if (settings.extraCourses) { checkExtraCourses(settings); }
  countExams();

  populateProgrammes(settings);
  if (!settings.extraProgrammes) { checkExtraProgrammes(settings); }
  if (!settings.emptyProgrammes) { checkForEmptyProgrammes(settings); }
  if (settings.emptyProgrammes) { checkEmptyProgrammes(settings); }

  checkProgrammelessCourses(settings);
  
  orderProgrammes(settings);

  putInCourses(settings);

  const cleaned = {
    programmes: orderedProgrammes.map(({programmeCode, name, language, terms}) => ({
      programmeCode,
      programmeName: name,
      programmeLanguage: language,
      terms: terms.map(({name, courses}) => ({
        termName: name,
        courses: courses.map(([courseCode, {name, credits, level, exams}]) => ({
          courseCode,
          courseName: name,
          courseCredit: credits,
          courseLevel: level,
          courseExamCount: exams,
          courseDirectory: `exams/${courseCode}`
        }))
      }))
    }))
  };  

  return cleaned;
}
