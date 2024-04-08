import * as fs from "fs";

function checkmds(file, data) {
  file = file.replace(/{{(\w+?)\.md}}/g, (match, filename) => {
    return checkReference(`${filename}.md`, data);
  });

  return file.replace(/{{(\w+?)\.mds}}/g, (match, filename) => {
    let elements = []

    data[`${filename}s`].forEach(determinor => {
       elements.push(checkReference(`${filename}.md`, {...data, ...determinor}));
    });
    return elements.join("\n");
  });
}

function checkvar(file, data) {
  return file = file.replace(/{{(\w+?)}}/g, (match, variableName) => {
    return data[variableName];
  })
}

export function checkReference(path, data) {
  let file = fs.readFileSync(`./descriptionCreator/static/${path}`).toString();

  file = checkmds(file, data);
  file = checkvar(file, data);

  return file;
}