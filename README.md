# RBXCode

## Introduction

RBXCode is a project environment that connects your Roblox projects to VSCode using HTTP requests. When starting RBXCode, 
scripts and folders from your Roblox project are copied to a local directory (game). You can then edit the created 
files using VSCode and changes will be reflected inside your Roblox project. However, all script manipulations besides 
editing should be done in Roblox Studio as only file edits are sent. Conversely, adding, removing, renaming or moving 
scripts in Roblox Studio updates your local directory.

## Why use RBXCode?

RBXCode is a simple solution for using VSCode for your Roblox projects. It differs from Rojo as RBXCode is not meant to 
be used with git. The local directory is overwritten by your Roblox project's content every time you start RBXCode, which 
means that everything should be saved within Roblox. However, you can move your local directory's content elsewhere if you 
wish to store it.

VSCode is extremely customizable and its autocomplete is much better than the one found in Roblox Studio's built-in script 
editor. When paired with the Roblox LSP extension, you get type information when you hover over something. Furthermore, you 
can use the Live Share extension in VSCode to make it possible for multiple people to collaborate on the same scripts.

## Getting Started

### Installation

Download from the Releases section and extract the files. Make sure that you have Node.js installed on your computer.

Open the RBXCode folder in VSCode and install dependencies:

    npm install

Move RBXCode.rbxmx to your local plugins folder. The folder can be found by opening the Plugins tab in Roblox Studio.

### Running RBXCode

Open the RBXCode folder in VSCode.

Start a local server by running:

    npm start

Use the plugin widget in Roblox Studio to connect to the local server.

## Notes

It is highly recommended to use the following extensions:
- Roblox LSP (adds autocomplete and type information, must-have)
- Live Share (enables real-time collaboration)
