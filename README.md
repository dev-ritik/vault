# vault
Symmetric Key based data backup &amp; recovery utility. Help to encrypt confidential files before backing up. 
(Basically reinventing the wheel!)
Pass is used to store the passphrase.

## Installation
- Clone the repo
- Run `./install.sh` for setting up the project
- Use `~/.config/vault/.targets` for adding paths for files to encrypt. Use `!`for excluding files. 
  (Supports `#` for commenting and `*` for multiple files)
- Add `pwd` to the path and run `./vault` for interacting

Sample `.targets` file
```
# Super secret file
/home/ritik/Desktop/secret_file.txt
/home/ritik/Desktop/secret_folder/* #Folder with secret files

!*.png #Png files are not important
```
## Usage
Allowed options:
```
  update		Update the index and encrypt the files
  decrypt		Decrypt required files to a location
  files     Location of files stored available to be shared
  all else	Print this message
```

For decrypt suboptions are,
```
 -o, --output           Output path to restore files to (default pwd)
 -b, --backup           Set of paths to restore files from. Use /* for all
```

## Example
- For encrypting files,
```bash
./vault.sh update
```
- For decrypting your files
```bash
./vault.sh decrypt -b /* -o /home/ritik/Desktop
```

## Dependencies
- `pass` - safely encrypts passwords (required at install).
- `gpg`- (or `gpg2`)- For encrypting and decrypting files.
- `find` - For finding (modified) files.
- `python`- For complex operations (TODO)