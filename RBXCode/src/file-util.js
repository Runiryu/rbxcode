import fs from 'fs-extra';

/**
 * Returns a file's name without its extension.
 * 
 * @param {string} fileName The file name
 * @returns {string} The file name without its extension
 */
export function getFileNameWithoutExtension(fileName) {
  const end = fileName.indexOf('.', 2);
  
  if (end >= 0) {
    return fileName.substring(0, end);
  }

  return fileName;
}

/**
 * Returns a file's extension.
 * 
 * @param {string} fileName The file name
 * @returns {string} The file extension
 */
export function getFileExtension(fileName) {
  const start = fileName.indexOf('.');
  if (start >= 0) {
    return fileName.substring(start);
  }
  return '';
}

/**
 * Returns a file with the given name regardless of its extension.
 * 
 * @param {string} path The path to search for
 * @param {boolean} includeDirectories Whether directories can be returned
 * @returns {string} The full name of the file that was found
 */
export async function getFileWithName(path, includeDirectories = false) {
  const items = path.split('/');
  const fileName = items.pop();
  const files = await fs.readdir(items.join('/'), { encoding: 'utf8' });
  const file = files.find((value) => {
    const pattern = includeDirectories ? `${fileName}(\.[A-Za-z])*` : `${fileName}(\.[A-Za-z])+`;
    return value.match(new RegExp(pattern));
  });

  return file;
}

/**
 * Returns the parent directory's path.
 * 
 * @param {string} path The file's path
 * @returns {string} The parent directory's path
 */
export function getParentDirectoryPath(path) {
  const directories = path.split('/');
  directories.pop();
  return directories.join('/');
}
