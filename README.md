# vault
Symmetric Key based data backup &amp; recovery utility. Help encrypting confidential files before backing up.
Pass is used to store the passphrase.

## Installation
- Clone the repo
- Run `./install.sh` for setting up the project
- Add `pwd` to the path and run `./vault` for interacting

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
 -o, --output           Output path to restore files to (default /tmp)
 -b, --backup           Set of paths to restore files from. Use /* for all
```

## Dependencies
- `pass` - safely encrypts passwords (required at install).
- `gpg`- (or `gpg2`)- For encrypting and decrypting files.
- `python`- For complex operations (TODO)