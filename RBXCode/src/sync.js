import fs from 'fs-extra';
import { watch } from 'chokidar';
import { exec } from 'child_process';

import * as fileUtil from './file-util.js';

export const instance = {
  instanceId: null,
  changes: [],
  ignored: {},
};

let watcher = watchDirectory('./game');

/**
 * Adds a new entry to the list of changes.
 * 
 * @param {string} path 
 */
async function registerChange(path) {
  try {
    const data = await fs.readFile(`./${path.replace(/\\/g, '/')}`, { encoding: 'utf8' });
    instance.changes.push({
      change: 'Edited',
      path,
      content: data,
    });
  } catch (err) {
    console.error(err);
    console.trace();
  }
}

/**
 * Watches a directory for file changes. If ignored[path] is true, the file
 * change is ignored once.
 * 
 * @param {string} directory The directory to watch
 * @returns {FSWatcher} An FSWatcher object
 */
function watchDirectory(directory) {
  const options = {
    awaitWriteFinish: {
      stabilityThreshold: 500,
    },
  };

  return watch(directory, options).on('change', async (path) => {
    if (!instance.ignored[path]) {
      await registerChange(path);
    }

    delete instance.ignored[path];
  });
}

/**
 * If a file exists at the given path, it is converted into a directory containing 
 * an init.extension file with its content. Otherwise, create an empty directory.
 * 
 * @param {string} path The path to convert
 */
async function toFolder(path) {
  try {
    const directory = fileUtil.getParentDirectoryPath(path);
    const file = await fileUtil.getFileWithName(path);

    if (file) {
      const extension = fileUtil.getFileExtension(file);

      if (extension) {
        await fs.outputFile(`${path}/init${extension}`, await fs.readFile(`${directory}/${file}`));
        await fs.remove(`${directory}/${file}`);
      }
    }

    await fs.ensureDir(path);
  } catch (err) {
    console.error(err);
    console.trace();
  }
}

/**
 * Writes to a file in the given directory. If fileName does not have an
 * extension, a folder is created instead. If a folder with the same name already
 * exists, an init.extension file is created inside that folder.
 * 
 * @param {string} directoryPath The path of the directory in which the file is
 * @param {string} fileName The name of the file to write to
 * @param {string} [content=''] The content to write if any
 */
async function writeTo(directoryPath, fileName, content = '') {
  try {
    const fileNameWithoutExtension = fileUtil.getFileNameWithoutExtension(fileName);
    const extension = fileUtil.getFileExtension(fileName);

    if (extension) {
      if (await fs.pathExists(`${directoryPath}/${fileNameWithoutExtension}`)) {
        // Write to an init file inside a folder named after the file
        await fs.outputFile(`${directoryPath}/${fileNameWithoutExtension}/init${extension}`, content);
      } else {
        // Write to a file
        await fs.outputFile(`${directoryPath}/${fileName}`, content);
      }
    } else {
      // Create a new folder
      await fs.ensureDir(`${directoryPath}/${fileName}`);
    }
  } catch (err) {
    console.error(err);
    console.trace();
  }
}

/**
 * Moves a file or directory to a new path.
 * 
 * @param {string} path The file's current path
 * @param {string} newPath The file's new path
 * @param {string} content The content to write
 */
async function moveTo(path, newPath, content = '') {
  try {
    const extension = fileUtil.getFileExtension(path);

    if (await fs.pathExists(path)) {

      if (extension) {
        await fs.remove(path);
        await writePath(newPath, content);
      } else {
        await fs.copy(path, newPath);
        await fs.remove(path);
      }
    } else {
      await writePath(newPath, content);
    }
  } catch (err) {
    console.error(err);
    console.trace();
  }
}

/**
 * Writes to a file at the given path. The file's existing content is overwritten.
 * 
 * @param {string} path The path to write to
 * @param {string} [content=''] The content to write if any
 */
async function writePath(path, content = '') {
  const relativePath = path.replace('game', '');
  const directories = relativePath.split('/');
  const fileName = directories.pop();
  let currentPath = 'game';

  for (const directory of directories) {
    await toFolder(`${currentPath}/${directory}`);
    currentPath += `/${directory}`;
  }

  await writeTo(currentPath, fileName, content);
}

/**
 * Returns the file extension associated to the LuaSourceContainer class.
 * 
 * @param {string} className The LuaSourceContainer class name
 * @returns {string} The file extension
 */
function getExtensionFromClass(className) {
  let extension;

  switch (className) {
    case 'ModuleScript':
      extension = '.lua';
      break;

    case 'Script':
      extension = '.server.lua';
      break;

    case 'LocalScript':
      extension = '.client.lua';
      break;

    default:
      extension = '';
  }

  return extension;
}

export async function init(content, instanceId) {
  instance.changes.length = 0;
  instance.instanceId = instanceId;
  await watcher.close();

  try {
    await fs.emptyDir('./game');
  } catch (err) {
    console.error(err);
    console.trace();
  }

  setTimeout(async () => {
    for (const script of content) {
      const extension = getExtensionFromClass(script.className);
      const filename = `game\\${script.path}${extension}`.replace(/\//g, '\\');

      try {
        instance.ignored[filename] = true;
        await writePath(`${script.path}${extension}`, script.content);

        setTimeout(() => {
          delete instance.ignored[filename];
        }, 1000);
      } catch (err) {
        console.error(err);
        console.trace();
      }
    }
  }, 1000);

  watcher = watchDirectory('game');
}

export async function update(incomingChanges) {
  for (const change of incomingChanges) {
    const extension = getExtensionFromClass(change.className);
    const path = `game/${change.path}${extension}`;
    const filename = `game\\${change.path}${extension}`.replace(/\//g, '\\');

    try {
      if (change.change === 'Added' || change.change === 'Edited') {
        instance.ignored[filename] = true;
        await writePath(path, change.content);
      } else if (change.change === 'Removed') {
        if (await fs.pathExists(path)) {
          await fs.remove(path);
        }
      } else if (change.change === 'Renamed' || change.change === 'Moved') {
        instance.ignored[filename] = true;
        moveTo(path, `game/${change.newPath}${extension}`, change.content);
      }
    } catch (err) {
      console.error(err);
      console.trace();
    }
  }
}

export function open(file) {
  const extension = getExtensionFromClass(file.className);

  exec(`code -g ./game/${file.path}${extension}:1 .`, (error, stdout, stderr) => {
    if (error) {
      console.error(error);
    }

    if (stdout) {
      console.info(stdout);
    }
    
    if (stderr) {
      console.error(stderr);
    }
  });
}
