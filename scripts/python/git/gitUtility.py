#!/usr/bin/env python3
# requires Python 3.6.x or above
import os
import subprocess
import sys
import fileinput

# get the full git commit hash
def get_git_commit_hash(repoPath):

    if ( not os.path.exists(repoPath) ):
        print (f"[ERROR]: Failed to get commit hash.  Reason: Path Not Found {repoPath}")
        return None

    cmd = f"git -C {repoPath} rev-parse  HEAD "


    stream = os.popen(cmd)
    output = stream.read().strip()

    return output

def get_git_tag(repoPath):

    if ( not os.path.exists(repoPath) ):
        print (f"[ERROR]: Failed to get commit hash.  Reason: Path Not Found {repoPath}")
        return None

    cmd = f"git -C {repoPath} describe "


    stream = os.popen(cmd)
    output = stream.read().strip()

    return output

# truncate string
def truncate_string(string, length):

    if (string == None):
        return None

    if (len(string) > length):
        return string[0:length]
    else:
        return string

def replace_text_in_file(filePath, find, replace):

    if (not os.path.exists(filePath)):
        print (F"[ERROR]: File does not exist: {filePath}")
        return None

    # read in the file
    with open(filePath, 'r') as file :
        text = file.read()

    # find/replace
    text = text.replace(find, replace)

    # write the file out again
    with open(filePath, 'w') as file:
        file.write(text)

    # return all went well
    return 0





# execute if this file is called directly
if ( __name__ == "__main__" ) :
    
    if (sys.argv.__len__() > 2) :
        path = (sys.argv[1])
        file = (sys.argv[2])

        # call the function
        hash = get_git_commit_hash(path)
        tag = get_git_tag(path)
        print (f"Origina Hash: {hash}")
        print (f"Git Tag: {tag}")

        resizedHash = (truncate_string(hash, 10))

        print (f"Resized Hash: {resizedHash}")

        if (hash != None and tag != None) :
            replace_text_in_file(file, "{VERSION_INFO}", f"{tag}.{resizedHash}")


    else:
        print("Required Arguments: RepoPath, VersionFile")

