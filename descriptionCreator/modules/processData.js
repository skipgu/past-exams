import * as fs from 'fs';

import courses from "../data/courses.json" assert {type: "json"};
import programmes from "../data/programmes.json" assert {type: "json"};
import programmeOrders from "../data/programmeOrders.json" assert {type: "json"};
import settings from "../settings.json" assert {type: "json"};

// List courses that are defined and have no exams
function checkEmptyCourses() {
  for (const course in courses) {
    if (!fs.existsSync(`./exams/${course}`)) {
      delete courses[course];
    }
  }
}

// List the courses that are not in any programmes
function checkExtraCourses() {
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

function countExams() {
  for (const course in courses) {
    if (fs.existsSync(`./exams/${course}`)) {
      const directories = fs.readdirSync(`./exams/${course}`, { withFileTypes: true });

      const examCount = directories.filter(directory => directory.isDirectory() && /^\d{4}-\d{2}-\d{2}$/.test(directory.name)).length;


      courses[course].exams = examCount;
    } else {
      courses[course].exams = 0;
    }
  }
}

function populateProgrammes() {
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
        const term = programmeOrders[programme].findIndex(term => term.name == "");
        programmeOrders[programme][term].courses.push(course);
        programmes[programme].courses.push(course);
      }
    }
  }
}

function checkExtraProgrammes() {
  for (const programme in programmes) {
    if (!programmes[programme].name) {
      delete programmes[programme];
    }
  }
}

function checkForEmptyProgrammes() {
  for (const programme in programmes) {
    if (!programmes[programme].courses) {
      delete programmes[programme];
    }
  }
}

function checkEmptyProgrammes() {
  const priority = settings.priorityProgrammes;
  priority.forEach(programme => {
    if (!programmes[programme]) programmes[programme] = {name: null, language: null, courses: [], terms: []}; 
  });
}

const orderedProgrammes = [];
function orderProgrammes() {
  const priority = settings.priorityProgrammes;
  priority.forEach(programme => {
    if (programmes[programme]) { orderedProgrammes.push({programmeCode: programme, ...programmes[programme]}); }
  });
  
  const remaining = Object.keys(programmes).filter(programme => !priority.includes(programme) && programme != "NONE").sort();
  remaining.forEach(programme => {
    orderedProgrammes.push({programmeCode: programme, ...programmes[programme]});
  });

  if (settings.extraCourses) {
    orderedProgrammes.push({programmeCode: "NONE", ...programmes.NONE});
  }
  
  orderedProgrammes.forEach(programme => {
    programme.terms = programmeOrders[programme.programmeCode];
  });
}

function checkProgrammelessCourses() {
  const courseArrays = Object.values(programmes).map(programme => programme.courses);
  
  const inProgramme = courseArrays.reduce((allCourses, currentCourses) => {
    return allCourses.concat(currentCourses);
  }, []);

  for (const course in courses) {
    if (!inProgramme.includes(course)) {
      if (!programmes.NONE) { programmes.NONE = {name: settings.courseNotAssigned, language: null, courses: []}; }
      programmes.NONE.courses.push(course);
    }
  }
  if (settings.extraCourses) {
    programmeOrders.NONE = [{name: "", courses: programmes.NONE.courses}]
  }
}

function putInCourses() {
  orderedProgrammes.forEach(programme => {
    if (programme.terms != undefined) {
      programme.terms.forEach(term => {
        term.courses = term.courses.map(course => [course, courses[course]]);
      });
    }
  });
}

export function processData() {
  delete courses.$schema;
  delete programmes.$schema;
  delete programmeOrders.$schema;

  if (!settings.emptyCourses) { checkEmptyCourses(); }
  if (settings.extraCourses) { checkExtraCourses(); }
  countExams();

  populateProgrammes();
  if (!settings.extraProgrammes) { checkExtraProgrammes(); }
  if (!settings.emptyProgrammes) { checkForEmptyProgrammes(); }
  if (settings.emptyProgrammes) { checkEmptyProgrammes(); }

  checkProgrammelessCourses();
  
  orderProgrammes();

  putInCourses();

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
          courseDirectory: `./exams/${courseCode}`
        }))
      }))
    }))
  };  

  return cleaned;
}