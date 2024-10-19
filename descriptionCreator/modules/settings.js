import schema from "../schemas/settings.json" assert {type: "json"};
import userSettings from "../settings.json" assert {type: "json"};

const defaultSettings = ((schema) => {
  const defaultSettings = {};
  const propertiesInSchema = schema.properties;
  for (let propertyKey in propertiesInSchema) {
    if (propertiesInSchema.hasOwnProperty(propertyKey)) {
      if ("default" in propertiesInSchema[propertyKey]) {
        defaultSettings[propertyKey] = propertiesInSchema[propertyKey].default;
      } else {
        console.log(`Schema error! ${propertyKey} is undefined!`);
        defaultSettings[propertyKey] = undefined;
      }
    }
  }
  return defaultSettings;
})(schema); 

delete defaultSettings.$schema;
delete userSettings.$schema;

export let settings = {
  ...defaultSettings,
  ...userSettings
};