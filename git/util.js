'use strict';

const fs = require('fs');
const exec = require('child_process').exec;
const readline = require('readline');

function getCurrentBranch() {
  return new Promise(function (resolve, reject) {
    exec('git symbolic-ref --short HEAD', (error, stdout) => {
      if (error) {
        reject(error);
      }
      resolve(stdout);
    });
  });
}

function getJiraIssue(branch) {
  let pattern = /DA-\d+/i;
  if (!pattern.test(branch)) {
    let master = /master/i;
    let error = '';
    if (master.test(branch)) {
      error = 'Current branch is master. Checkout a valid branch.';
    } else {
      error = 'Branch does not contain reference to a JIRA-issue.';
    }
    throw new Error(error);
  }
  return pattern.exec(branch)[0];
}

function getCommitMessage(file) {
  return new Promise(function (resolve, reject) {
    fs.readFile(file, 'utf-8', (error, data) => {
      if (error) {
        reject(error);
      }
      resolve(data);
    });
  });
}

function getPushRefs() {
  return new Promise(function (resolve) {
    var rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false
    });

    rl.on('line', line => {
      resolve(line);
    });
  });
}

module.exports = {
  getCurrentBranch: getCurrentBranch,
  getJiraIssue: getJiraIssue,
  getCommitMessage: getCommitMessage,
  getPushRefs: getPushRefs
};

