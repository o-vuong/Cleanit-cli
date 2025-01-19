// Required Node.js modules
const fs = require('fs');
const path = require('path');
const inquirer = require('inquirer');
const chalk = require('chalk');

// Utility functions
const checkDirectory = (directory) => {
    if (!fs.existsSync(directory) || !fs.lstatSync(directory).isDirectory()) {
        console.error(chalk.red(`Error: Directory does not exist: ${directory}`));
        process.exit(1);
    }
};

const createFolder = (folder) => {
    if (!fs.existsSync(folder)) {
        fs.mkdirSync(folder, { recursive: true });
        console.log(chalk.cyan(`Created folder: ${folder}`));
    }
};

const cleanPath = (filePath) => filePath.replace(/\/\\+/g, '/');

const formatLog = (action, source, target, color) => {
    const cleanSource = cleanPath(source);
    const cleanTarget = cleanPath(target);
    return `${chalk.keyword(color)(action)}: ${path.basename(cleanSource)} ${chalk.cyan('→')} ${chalk.cyan(cleanTarget)}`;
};

// Main function
(async () => {
    const answers = await inquirer.prompt([
        {
            type: 'input',
            name: 'directory',
            message: 'Enter directory to tidy up (default: current directory):',
            default: process.cwd(),
        },
        {
            type: 'confirm',
            name: 'dryRun',
            message: 'Enable dry-run mode (simulate without changes)?',
        },
        {
            type: 'confirm',
            name: 'ignoreDotfiles',
            message: 'Ignore dotfiles (files starting with '.')?',
        },
    ]);

    const directory = answers.directory;
    const dryRun = answers.dryRun;
    const ignoreDotfiles = answers.ignoreDotfiles;

    checkDirectory(directory);

    const looseFiles = fs.readdirSync(directory).filter((file) => {
        const filePath = path.join(directory, file);
        return fs.lstatSync(filePath).isFile();
    });

    if (looseFiles.length === 0) {
        console.log(chalk.red('No loose files found in the directory!'));
        return;
    }

    const logEntries = [];

    console.log(chalk.cyan('Organizing files by extension...\n'));

    looseFiles.forEach((file) => {
        if (ignoreDotfiles && file.startsWith('.')) return;

        const ext = path.extname(file).slice(1) || 'others';
        const targetFolder = path.join(directory, ext);

        if (!dryRun) {
            createFolder(targetFolder);
            const source = path.join(directory, file);
            const target = path.join(targetFolder, file);
            fs.renameSync(source, target);
            logEntries.push(formatLog('Moved', source, targetFolder, 'green'));
        } else {
            logEntries.push(formatLog('Dry-run', file, targetFolder, 'yellow'));
        }
    });

    if (logEntries.length > 0) {
        console.log(chalk.cyan('File Organization Summary:\n'));
        logEntries.forEach((entry) => console.log(entry));
    } else {
        console.log(chalk.red('No files were moved.'));
    }

    console.log(chalk.cyan('File organization complete!'));
})();
