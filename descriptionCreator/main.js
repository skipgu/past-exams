import * as fs from "fs";

import { checkReference } from './modules/checkReferences.js';
import { processData } from './modules/processData.js';
import { settings } from './modules/settings.js';

/**
 * Main function of the Description creator
 * @param {{[x: string]: any}} settings 
 */
function main(settings) {
  let programmes = processData(settings);

  fs.writeFileSync("./exams.json", JSON.stringify(programmes,null,2), "utf-8");

  fs.writeFileSync("./README.md", checkReference("structure.md", programmes), "utf-8");
}

main(settings);