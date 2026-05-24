const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:8000',
    specPattern: 'cypress/e2e/**/*.cy.js',
    supportFile: 'cypress/support/e2e.js',
    video: false,
    screenshotOnRunFailure: true,
    screenshotsFolder: 'cypress/screenshots',
    reporter: 'junit',
    reporterOptions: {
      mochaFile: 'cypress/results/junit-[hash].xml',
      toConsole: true,
    },
    env: {
      apiUrl: 'http://localhost:8000',
    },
  },
});
